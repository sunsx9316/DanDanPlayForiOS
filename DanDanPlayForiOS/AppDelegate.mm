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
#import "NSString+Tools.h"
#import "CacheManager.h"
#import "DownloadViewController.h"
#import "QRScanerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

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

- (void)applicationWillResignActive:(UIApplication *)application {
 
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

//唤醒
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString *content = [UIPasteboard generalPasteboard].string;
    
    //系统剪贴板有磁力链并且第一次打开
    if ([content isMagnet]) {
        //防止重复弹出
        [UIPasteboard generalPasteboard].string = @"";
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UINavigationController *nav = (UINavigationController *)tabBarController.selectedViewController;
        
        void(^downloadAction)(NSString *) = ^(NSString *magnet){
            
            [LinkNetManager linkAddDownloadWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress magnet:magnet completionHandler:^(JHLinkDownloadTask *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    [[CacheManager shareCacheManager] addLinkDownload];
                    
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"创建下载任务成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [vc addAction:[UIAlertAction actionWithTitle:@"下载列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        DownloadViewController *vc = [[DownloadViewController alloc] init];
                        vc.hidesBottomBarWhenPushed = YES;
                        [nav pushViewController:vc animated:YES];
                    }]];
                    
                    [vc addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil]];
                    
                    [nav presentViewController:vc animated:YES completion:nil];
                }
            }];
        };
        
        if ([CacheManager shareCacheManager].linkInfo == nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"检测到磁力链" message:@"需要连接到电脑端才能下载~" preferredStyle:UIAlertControllerStyleAlert];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"扫码链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                QRScanerViewController *vc = [[QRScanerViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                @weakify(self)
                vc.linkSuccessCallBack = ^(JHLinkInfo *info) {
                    @strongify(self)
                    if (!self) return;
                    
                    downloadAction(content);
                };
                [nav pushViewController:vc animated:YES];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [nav presentViewController:vc animated:YES completion:nil];
        }
        else {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"检测到磁力链" message:@"是否下载" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                downloadAction(content);
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [nav presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        NSURL *toURL = [[[UIApplication sharedApplication] documentsURL] URLByAppendingPathComponent:[url lastPathComponent]];
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:toURL error:nil];
        return YES;
    }
    
    return result;
}
#else

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if (!result) {
        NSURL *toURL = [[[UIApplication sharedApplication] documentsURL] URLByAppendingPathComponent:[url lastPathComponent]];
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:toURL error:nil];
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
