//
//  DDPPlayNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayNavigationController.h"
#import "DDPPlayerViewController.h"

@interface DDPPlayNavigationController ()

@end

@implementation DDPPlayNavigationController

- (instancetype)initWithModel:(DDPVideoModel *)model {
    DDPPlayerViewController *vc = [[DDPPlayerViewController alloc] init];
    vc.model = model;
    
    if (self = [super initWithRootViewController:vc]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
}


//设置是否允许自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}

//设置支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

//设置presentation方式展示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [DDPCacheManager shareCacheManager].playInterfaceOrientation;
}

- (void)handleDeviceOrientationDidChange:(NSNotification *)aNotification {
    UIDeviceOrientation orientation = [aNotification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            [DDPCacheManager shareCacheManager].playInterfaceOrientation = (UIInterfaceOrientation)orientation;
            break;
        default:
            break;
    }
}

@end
