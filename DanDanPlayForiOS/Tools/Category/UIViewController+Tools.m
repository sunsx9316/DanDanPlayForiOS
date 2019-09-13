//
//  UIViewController+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIViewController+Tools.h"

#if !DDPAPPTYPEISMAC
#import "DDPPlayNavigationController.h"
#import "DDPMatchViewController.h"
#endif

@implementation UIViewController (Tools)
- (void)setNavigationBarWithColor:(UIColor *)color {
    if ([color isEqual:[UIColor clearColor]]) {
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = YES;
        // 将状态栏和导航条设置成透明
        UIImage *image = [[UIImage alloc] init];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = image;
    }
    else {
        self.navigationController.navigationBar.barTintColor = color;
        self.navigationController.navigationBar.tintColor = color;
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }
}


- (void)tryAnalyzeVideo:(DDPVideoModel *)model {
    [DDPMethod matchVideoModel:model completion:nil];
}

@end
