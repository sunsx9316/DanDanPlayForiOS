//
//  UIApplication+DDPTools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/22.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "UIApplication+DDPTools.h"

@implementation UIApplication (DDPTools)

- (UIWindow *)ddp_mainWindow {
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject;
        if (windowScene != nil) {
            UIWindow *aWindow = windowScene.windows.firstObject;
            return aWindow;
        }
    }
    
    return [UIApplication sharedApplication].delegate.window;
}

- (NSString *)appDisplayName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (UINavigationController *)topNavigationController {
    UINavigationController *nav = nil;
    UITabBarController *tabbarVC = (UITabBarController *)self.ddp_mainWindow.rootViewController;
    if ([tabbarVC isKindOfClass:[UITabBarController class]]) {
        UINavigationController *aNav = tabbarVC.selectedViewController;
        if ([aNav isKindOfClass:[UINavigationController class]]) {
            nav = aNav;
        }
    }
    return nav;
}

@end
