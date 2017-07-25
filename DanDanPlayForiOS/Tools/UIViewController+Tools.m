//
//  UIViewController+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIViewController+Tools.h"

@implementation UIViewController (Tools)
- (void)setNavigationBarWithColor:(UIColor *)color {
    if ([color isEqual:[UIColor clearColor]]) {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = YES;
        
        // 将状态栏和导航条设置成透明
        UIImage *image = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }
    else {
        self.navigationController.navigationBar.barTintColor = color;
        self.navigationController.navigationBar.tintColor = color;
        self.navigationController.navigationBar.translucent = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

@end
