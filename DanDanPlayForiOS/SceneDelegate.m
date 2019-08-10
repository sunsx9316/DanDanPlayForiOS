//
//  SceneDelegate.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/21.
//  Copyright © 2019 jim. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

#import "SceneDelegate.h"
#import <Foundation/Foundation.h>
#import "DDPMainViewController.h"

#if DDPAPPTYPEISMAC
#import <UIKit/NSToolbar+UIKitAdditions.h>
#import <AppKit/NSToolbarItemGroup.h>

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
    let titlebar = windowScene.titlebar;
    let toolbar = [[NSToolbar alloc] initWithIdentifier: @"NSToolbar"];
    titlebar.toolbar = toolbar;
    toolbar.delegate = self;
    toolbar.allowsUserCustomization = false;
    toolbar.centeredItemIdentifier = @"main";
    titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
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
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

#if DDPAPPTYPEISMAC
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
#endif

@end

#endif
