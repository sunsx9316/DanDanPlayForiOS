//
//  JHBaseNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseNavigationController.h"

@interface JHBaseNavigationController ()

@end

@implementation JHBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate {
    return YES;
}

//设置支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//设置presentation方式展示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
