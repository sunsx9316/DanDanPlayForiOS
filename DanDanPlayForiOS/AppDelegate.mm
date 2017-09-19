//
//  AppDelegate.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <IQKeyboardManager.h>
#import <Bugly/Bugly.h>
#import <UMSocialCore/UMSocialCore.h>
#import <AVFoundation/AVFoundation.h>
#import "JHMediaPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    UIBackgroundTaskIdentifier _bgTaskId;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"%@", [UIApplication sharedApplication].documentsURL);
//    [CacheManager shareCacheManager].folderCache = nil;
    [self configIQKeyboardManager];
    [self configBugly];
    [self configUMShare];
    
    MainViewController *vc = [[MainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = BACK_GROUND_COLOR;
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//进入后台
- (void)applicationWillResignActive:(UIApplication *)application {
    //设置锁屏界面
    JHMediaPlayer *player = [CacheManager shareCacheManager].mediaPlayer;
    if (!player) return;
    
    VideoModel *model = [CacheManager shareCacheManager].currentPlayVideoModel;
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    _bgTaskId = [AppDelegate backgroundPlayerID:_bgTaskId];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (model.name.length) {
        dict[MPMediaItemPropertyTitle] = model.name;
    }
    
    UIImage *img = [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:model.quickHash]]];
    if (img) {
        dict[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:img];
    }
    //设置歌曲时长
    dict[MPMediaItemPropertyPlaybackDuration] = @(player.length);
    //设置已经播放时长
    dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(player.currentTime);
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:[[UIApplication sharedApplication] documentsURL] error:nil];
        return YES;
    }
    
    return result;
}
#else

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if (!result) {
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:[[UIApplication sharedApplication] documentsURL] error:nil];
        return YES;
    }
    return result;
}

#endif

#pragma mark - 私有方法
- (void)configIQKeyboardManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enableAutoToolbar = NO;
    manager.shouldResignOnTouchOutside = YES;
}

- (void)configBugly {
    [Bugly startWithAppId:BUGLY_KEY];
}

- (void)configUMShare {
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:UM_SHARE_KEY];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQ_APP_KEY appSecret:nil redirectURL:nil];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:WEIBO_APP_KEY appSecret:WEIBO_APP_SECRET redirectURL:WEIBO_REDIRECT_URL];
}

+ (UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId {
    //设置并激活音频会话类别
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    //允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId != UIBackgroundTaskInvalid && backTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    JHMediaPlayer *player = [CacheManager shareCacheManager].mediaPlayer;
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        {
            if (player.isPlaying == NO) {
                [player play];
            }
        }
            break;
        case UIEventSubtypeRemoteControlPause:
        {
            if (player.isPlaying == YES) {
                [player pause];
            }
        }
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
        {
            if (player.isPlaying == YES) {
                [player pause];
            }
            else {
                [player play];
            }
        }
            
        default:
            break;
    }
}

@end
