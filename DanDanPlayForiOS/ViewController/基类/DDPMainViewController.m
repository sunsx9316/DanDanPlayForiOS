//
//  DDPMainViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMainViewController.h"
#import "DDPFileViewController.h"
#import "DDPMineViewController.h"
#import "DDPHomePageViewController.h"
#import "DDPBaseNavigationController.h"

@interface DDPMainViewController ()<UITabBarControllerDelegate>
@end

@implementation DDPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *homeVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"main_bangumi"] selectImg:[UIImage imageNamed:@"main_bangumi"] rootVC:[[DDPHomePageViewController alloc] init] title:nil];
    UINavigationController *fileVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"main_file"] selectImg:[UIImage imageNamed:@"main_file"] rootVC:[[DDPFileViewController alloc] init] title:nil];
    UINavigationController *settingVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"main_mine"] selectImg:[UIImage imageNamed:@"main_mine"] rootVC:[[DDPMineViewController alloc] init] title:nil];
    
    self.viewControllers = @[homeVC, fileVC, settingVC];
    
    self.tabBar.translucent = NO;
    self.delegate = self;
}

- (BOOL)shouldAutorotate {
    return ddp_isPad();
}

//设置支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (ddp_isPad()) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

//设置presentation方式展示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 2) {
        [[DDPDownloadManager shareDownloadManager] startObserverTaskInfo];
    }
    else {
        [[DDPDownloadManager shareDownloadManager] stopObserverTaskInfo];
    }
}

#pragma mark - 私有方法
- (UINavigationController *)navigationControllerWithNormalImg:(UIImage *)normalImg selectImg:(UIImage *)selectImg rootVC:(UIViewController *)rootVC title:(NSString *)title {
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:normalImg selectedImage:[[selectImg imageByTintColor:[UIColor ddp_mainColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *navVC = [[DDPBaseNavigationController alloc] initWithRootViewController:rootVC];
    navVC.tabBarItem = item;
    if (ddp_isPad() == NO) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    
    return navVC;
}

@end
