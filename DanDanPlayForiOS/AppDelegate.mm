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
#import <YYCategories/NSData+YYAdd.h>

#if !DDPAPPTYPEISMAC
#import <Bugly/Bugly.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UMMobClick/MobClick.h>
#else
#import <SSZipArchive/SSZipArchive.h>
#import <DDPShare/DDPShare.h>
#import "DDPBaseMessage+Hook.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LOG_DEBUG(DDPLogModuleOther, @"documentsURL: %@", [UIApplication sharedApplication].documentsURL);
    
    [self configIQKeyboardManager];
    [self configBugly];
    [self configUM];
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
    [LogHelper flush];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

//唤醒
- (void)applicationDidBecomeActive:(UIApplication *)application {
#if !DDPAPPTYPEISREVIEW
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
    [LogHelper deinitLog];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    BOOL result = NO;
    
#if !DDPAPPTYPEISMAC
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

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder API_AVAILABLE(ios(13.0)) {
    [super buildMenuWithBuilder:builder];
    [builder removeMenuForIdentifier:UIMenuFormat];
    [builder removeMenuForIdentifier:UIMenuFile];
    
    let helpCommad = [UIKeyCommand keyCommandWithInput:@"" modifierFlags:kNilOptions action:@selector(showHelpGuild)];
    helpCommad.title = @"FAQ";

    [builder replaceChildrenOfMenuForIdentifier:UIMenuHelp fromChildrenBlock:^NSArray<UIMenuElement *> * _Nonnull(NSArray<UIMenuElement *> * _Nonnull) {
        return @[helpCommad];
    }];
}

- (void)showHelpGuild {
    let path = [[NSBundle mainBundle] pathForResource:@"FAQ" ofType:@"html"];
    if (path) {
        [UIApplication.sharedApplication openURL:[NSURL fileURLWithPath:path] options:@{} completionHandler:nil];
    }
}

#pragma mark - 私有方法
- (void)configIQKeyboardManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enableAutoToolbar = NO;
    manager.shouldResignOnTouchOutside = YES;
}

- (void)configBugly {
    #if !DDPAPPTYPEISMAC
    [Bugly startWithAppId:ddp_buglyKey];
    #endif
}

- (void)configUM {
#if !DDPAPPTYPEISMAC
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

- (void)configOther {
    if (@available(iOS 11.0, *)) {
        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
//    [UILabel appearance].font = [UIFont ddp_normalSizeFont];
    [UITextView appearance].tintColor = [UIColor ddp_mainColor];
    
    if (@available(iOS 13.0, *)) {
        UIImage *normalBgImage = [[UIImage imageWithColor:UIColor.lightGrayColor size:CGSizeMake(10, 10)] imageByRoundCornerRadius:4];
        normalBgImage = [normalBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [UIStepper.appearance setBackgroundImage:normalBgImage forState:UIControlStateNormal];
        
        UIImage *selectedBgImage = [[UIImage imageWithColor:UIColor.grayColor size:CGSizeMake(10, 10)] imageByRoundCornerRadius:4];
        selectedBgImage = [selectedBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [UIStepper.appearance setBackgroundImage:selectedBgImage forState:UIControlStateHighlighted];        
    }
    
    
    [[DDPSharedNetManager sharedNetManager] resetJWTToken:[DDPCacheManager shareCacheManager].currentUser.JWTToken];
    
#if DDPAPPTYPEISMAC
    let applicationDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSUserDomainMask] lastObject].path;
    let tempPath = [applicationDirectory stringByAppendingPathComponent:@"弹弹Play播放器.app"];
    
    void(^copyAction)(void) = ^{
        let appPathInBundle = [[NSBundle mainBundle] pathForResource:@"inner_player" ofType:@"zip"];
        [SSZipArchive unzipFileAtPath:appPathInBundle toDestination:applicationDirectory];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        copyAction();
    } else {
        let plistPath = [tempPath stringByAppendingPathComponent:@"Contents/Info.plist"];
        let plistDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSString *localVersion = plistDic[@"CFBundleVersion"];
        NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InnerPlayerVersion"];
        if ([localVersion compare:currentVersion options:NSNumericSearch] == NSOrderedAscending) {
            [NSFileManager.defaultManager removeItemAtPath:tempPath error:nil];
            copyAction();
        }
    }
#else
    
    [LogHelper setupLog];
    
#endif
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
