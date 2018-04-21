//
//  AppDelegate.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AppDelegate.h"
#import "DDPMainViewController.h"
#import <IQKeyboardManager.h>
#import <Bugly/Bugly.h>
#import <JSPatchPlatform/JSPatch.h>
#import <UMSocialCore/UMSocialCore.h>
#import <AVFoundation/AVFoundation.h>
#import "DDPMediaPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+Tools.h"
#import "DDPCacheManager.h"
#import "DDPDownloadViewController.h"
#import "DDPQRScannerViewController.h"
#import "DDPDownloadManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@", [UIApplication sharedApplication].documentsURL);
    
    [self configJSPatch];
    [self configIQKeyboardManager];
    [self configBugly];
    [self configUMShare];
    [self configDDLog];
    [self configOther];
    
    DDPMainViewController *vc = [[DDPMainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor ddp_backgroundColor];
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
            
            [DDPLinkNetManagerOperation linkAddDownloadWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress magnet:magnet completionHandler:^(DDPLinkDownloadTask *responseObject, NSError *error) {
                if (error) {
                    [[UIApplication sharedApplication].keyWindow showWithError:error];
                }
                else {
                    [[DDPDownloadManager shareDownloadManager] startObserverTaskInfo];
                    
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"创建下载任务成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [vc addAction:[UIAlertAction actionWithTitle:@"下载列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        DDPDownloadViewController *vc = [[DDPDownloadViewController alloc] init];
                        vc.hidesBottomBarWhenPushed = YES;
                        [nav pushViewController:vc animated:YES];
                    }]];
                    
                    [vc addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil]];
                    
                    [nav presentViewController:vc animated:YES completion:nil];
                }
            }];
        };
        
        if ([DDPCacheManager shareCacheManager].linkInfo == nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"检测到磁力链" message:@"需要连接到电脑端才能下载~" preferredStyle:UIAlertControllerStyleAlert];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"扫码连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                DDPQRScannerViewController *vc = [[DDPQRScannerViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                @weakify(self)
                vc.linkSuccessCallBack = ^(DDPLinkInfo *info) {
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

- (void)configJSPatch {
    BOOL localTest = false;
    
#ifdef DEBUG
    [JSPatch setupDevelopment];
#else
    localTest = false;
#endif
    
    if (localTest) {
        [JSPatch testScriptInBundle];
    }
    else {
        [JSPatch startWithAppKey:@"372ca85cc624bb14"];
        [JSPatch setupRSAPublicKey:@"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDIjsQtfDJvKO4kFzUlgnwtukiR\ni+IF7hxDWqd4z7Y6yqR3nc0BWXLaFL8qa+0dBN8tyO8xPUPZxzgv6dg0EV6vN8wo\n8O2QSK9unVTkzAli4bGrC+3JG4dp0z25YPStQba5hAbyHcm7KklBwPL6j3rMmzer\neLv31kZzjS4tVeCtkQIDAQAB\n-----END PUBLIC KEY-----"];
        
        if ([DDPCacheManager shareCacheManager].user.identity > 0) {
            [JSPatch setupUserData:@{@"userId" : [NSString stringWithFormat:@"%ld", [DDPCacheManager shareCacheManager].user.identity]}];
        }
        
        [JSPatch sync];
    }
}

- (void)configDDLog {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)configOther {
    if (@available(iOS 11.0, *)) {
        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    DDPMediaPlayer *player = [DDPCacheManager shareCacheManager].mediaPlayer;
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
