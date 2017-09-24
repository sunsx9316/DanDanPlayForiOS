//
//  PlayNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayNavigationController.h"
#import "PlayerViewController.h"
#import "FileManagerNavigationBar.h"

@interface PlayNavigationController ()

@end

@implementation PlayNavigationController

- (instancetype)initWithModel:(VideoModel *)model {
    PlayerViewController *vc = [[PlayerViewController alloc] init];
    vc.model = model;
    
    if (self = [super initWithNavigationBarClass:[FileManagerNavigationBar class] toolbarClass:nil]) {
        [self setViewControllers:@[vc]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


//设置是否允许自动旋转
//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//设置支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

//设置presentation方式展示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [CacheManager shareCacheManager].playInterfaceOrientation;
}

- (void)handleDeviceOrientationDidChange:(NSNotification *)aNotification {
    UIDeviceOrientation orientation = [aNotification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            [CacheManager shareCacheManager].playInterfaceOrientation = (UIInterfaceOrientation)orientation;
            break;
        default:
            break;
    }
    
}

@end
