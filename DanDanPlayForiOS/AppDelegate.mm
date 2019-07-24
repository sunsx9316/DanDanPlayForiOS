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
#import <AVFoundation/AVFoundation.h>
#import "DDPMediaPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+Tools.h"
#import "DDPCacheManager.h"
#import "DDPDownloadViewController.h"
#import "DDPQRScannerViewController.h"
#import "DDPDownloadManager.h"
//#import <BayMaxProtector.h>
#import "DDPPlayNavigationController.h"
#import "DDPSharedNetManager.h"

#if !TARGET_OS_UIKITFORMAC
#import <Bugly/Bugly.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UMMobClick/MobClick.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@", [UIApplication sharedApplication].documentsURL);
    
    [self configIQKeyboardManager];
    [self configBugly];
    [self configUM];
    [self configDDLog];
    [self configOther];
    
    if (@available(iOS 13.0, *)) {
        
    } else {
        DDPMainViewController *vc = [[DDPMainViewController alloc] init];
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor ddp_backgroundColor];
        self.window.rootViewController = vc;
        [self.window makeKeyAndVisible];        
    }
    
    
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
#if DDPAPPTYPE != 1
    NSString *content = [UIPasteboard generalPasteboard].string;
    
    //系统剪贴板有磁力链并且第一次打开
    if ([content isMagnet]) {
        //防止重复弹出
        [UIPasteboard generalPasteboard].string = @"";
        
        UITabBarController *tabBarController = (UITabBarController *)application.ddp_mainWindow.rootViewController;
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
#endif
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
    BOOL result = NO;
#if !TARGET_OS_UIKITFORMAC
    result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
#endif
    
    if (!result) {
        if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqual:@"com.apple.DocumentsApp"]) {
            
            if ([application.ddp_mainWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabvc = (UITabBarController *)application.ddp_mainWindow.rootViewController;
                
                UINavigationController *nav = tabvc.selectedViewController;
                if ([nav isKindOfClass:[UINavigationController class]]) {
                    let file = [[DDPFile alloc] initWithFileURL:url type:DDPFileTypeDocument];
                    let video = file.videoModel;
                    
                    [nav tryAnalyzeVideo:video];
                }
            }
        }
        else {
            NSURL *toURL = [[[UIApplication sharedApplication] documentsURL] URLByAppendingPathComponent:[url lastPathComponent]];
            [[NSFileManager defaultManager] copyItemAtURL:url toURL:toURL error:nil];
        }
        
        return YES;
    }
    return result;
}

#endif

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}
#endif

#pragma mark - 私有方法
- (void)configIQKeyboardManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enableAutoToolbar = NO;
    manager.shouldResignOnTouchOutside = YES;
}

- (void)configBugly {
    #if !TARGET_OS_UIKITFORMAC
    [Bugly startWithAppId:ddp_buglyKey];
    #endif
}

- (void)configUM {
#if !TARGET_OS_UIKITFORMAC
    if (ddp_UMShareKey.length != 0) {
        [[UMSocialManager defaultManager] openLog:YES];
        [[UMSocialManager defaultManager] setUmSocialAppkey:ddp_UMShareKey];
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:ddp_QQAppKey appSecret:nil redirectURL:nil];
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:ddp_weiboAppKey appSecret:ddp_weiboSecretKey redirectURL:ddp_weiboRedirectURL];
        
        //友盟统计
        UMConfigInstance.appKey = ddp_UMShareKey;
        UMConfigInstance.channelId = @"App Store";
        [MobClick setAppVersion:[UIApplication sharedApplication].appVersion];
        [MobClick startWithConfigure:UMConfigInstance];        
    }
#endif
}

- (void)configDDLog {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)configOther {
    if (@available(iOS 11.0, *)) {
        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [UILabel appearance].font = [UIFont ddp_normalSizeFont];
    [UILabel appearance].textColor = [UIColor blackColor];
    [UITextView appearance].tintColor = [UIColor ddp_mainColor];
    [UITextField appearance].textColor = [UIColor blackColor];
    
    [[DDPSharedNetManager sharedNetManager] resetJWTToken:[DDPCacheManager shareCacheManager].currentUser.JWTToken];
}

- (void)configCrash {
//#ifndef DEBUG
//    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll catchErrorHandler:^(BayMaxCatchError * _Nullable error) {
//        NSDictionary *errorInfos = error.errorInfos;
//        [Bugly reportExceptionWithCategory:3 name:errorInfos[BMPErrorUnrecognizedSel_Func] reason:errorInfos[BMPErrorUnrecognizedSel_Reason] callStack:errorInfos[BMPErrorCallStackSymbols] extraInfo:errorInfos terminateApp:false];
//    }];
//#endif
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
