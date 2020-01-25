//
//  SceneDelegate.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/21.
//  Copyright © 2019 jim. All rights reserved.
//

#import "SceneDelegate.h"
#import <Foundation/Foundation.h>
#import "DDPMainViewController.h"

#if DDPAPPTYPEISMAC
#import <UIKit/NSToolbar+UIKitAdditions.h>
#import <AppKit/NSToolbarItemGroup.h>
#import <DDPShare/DDPShare.h>
#import "DDPUpdateNetManagerOperation.h"

@interface SceneDelegate ()<NSToolbarDelegate>
@end

#endif

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

    DDPMainViewController *vc = [[DDPMainViewController alloc] init];
    self.window.backgroundColor = [UIColor ddp_backgroundColor];
    self.window.rootViewController = vc;
#if DDPAPPTYPEISMAC
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    windowScene.sizeRestrictions.maximumSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    let titlebar = windowScene.titlebar;
    let toolbar = [[NSToolbar alloc] initWithIdentifier: @"NSToolbar"];
    titlebar.toolbar = toolbar;
    toolbar.delegate = self;
    toolbar.allowsUserCustomization = false;
    toolbar.centeredItemIdentifier = @"main";
    titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
    
    @weakify(self)
    [DDPUpdateNetManagerOperation checkUpdateInfoWithCompletionHandler:^(DDPVersion * _Nonnull model, NSError * _Nonnull error) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        if (model.shouldUpdate) {
            [self showUpdateAlertWithModel:model force:model.forceUpdate];
        }
    }];
#endif
    
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {

}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {

}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

#if DDPAPPTYPEISMAC
- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    let context = URLContexts.anyObject;
    id<DDPMessageProtocol>model = [context.URL makeMessage];
    [[DDPMessageManager sharedManager] receiveMessage:model];
}


#pragma mark - NSToolbarDelegate
- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:@"main"]) {
        let items = [DDPMainViewController items];
        
        NSMutableArray <NSString *>*titles = [NSMutableArray arrayWithCapacity:items.count];
        NSMutableArray <NSString *>*labels = [NSMutableArray arrayWithCapacity:items.count];
        
        [items enumerateObjectsUsingBlock:^(DDPMainVCItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [titles addObject:obj.name];
            [labels addObject:obj.vcClassName];
        }];
        
        NSToolbarItemGroup *group = [NSToolbarItemGroup groupWithItemIdentifier:itemIdentifier titles:titles selectionMode:NSToolbarItemGroupSelectionModeSelectOne labels:labels target:self action:@selector(toolbarGroupSelectionChanged:)];
        group.selectedIndex = 0;
        return group;
    }
    return nil;
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[@"main"];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (void)toolbarGroupSelectionChanged:(NSToolbarItemGroup *)sender {
    UITabBarController *vc = (UITabBarController *)self.window.rootViewController;
    vc.selectedIndex = sender.selectedIndex;
}

- (void)showUpdateAlertWithModel:(DDPVersion *)model force:(BOOL)force {
    
    let ignoreVersion = DDPCacheManager.shareCacheManager.ignoreVersion;
    if ([ignoreVersion isEqualToString:model.version] && force == NO) {
        return;
    }
    
    let title = [NSString stringWithFormat:@"检测到新版本 %@", model.shortVersion];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:model.desc preferredStyle:UIAlertControllerStyleAlert];
    
    if (model.forceUpdate == NO) {
        [vc addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            DDPCacheManager.shareCacheManager.ignoreVersion = model.version;
        }]];
    }
    
    let view = UIApplication.sharedApplication.ddp_mainWindow.rootViewController.view;
    
    
    [vc addAction:[UIAlertAction actionWithTitle:@"确定升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *progressHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeDeterminateHorizontalBar InView:view];
        [progressHUD showAnimated:YES];
        
        [DDPUpdateNetManagerOperation downloadLatestAppWithURL:model.url progressHandler:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHUD.progress = downloadProgress.fractionCompleted;
            });
        } completionHandler:^(NSURL * _Nonnull model, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressHUD hideAnimated:YES];
                if (model) {
                    [[UIApplication sharedApplication] openURL:model options:@{} completionHandler:nil];
                } else {
                    [self showUpdateFaileAlert];
                }
            });
        }];
    }]];
    
    [UIApplication.sharedApplication.ddp_mainWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)showUpdateFaileAlert {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载失败，是否前往官网下载？" preferredStyle:UIAlertControllerStyleAlert];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DDPLAY_OFFICIAL_SITE] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    
    [UIApplication.sharedApplication.ddp_mainWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

#endif

@end
