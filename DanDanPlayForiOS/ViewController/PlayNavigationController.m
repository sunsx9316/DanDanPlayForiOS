//
//  PlayNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayNavigationController.h"
#import "PlayerViewController.h"

@interface PlayNavigationController ()

@end

@implementation PlayNavigationController

- (instancetype)initWithModel:(VideoModel *)model {
    PlayerViewController *vc = [[PlayerViewController alloc] init];
    vc.model = model;
    return [self initWithRootViewController:vc];
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
    return UIInterfaceOrientationLandscapeLeft;
}

@end
