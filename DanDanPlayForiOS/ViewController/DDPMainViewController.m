//
//  DDPMainViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMainViewController.h"
#import "DDPMineViewController.h"
#import "DDPNewHomePagePackageViewController.h"
#import "DDPBaseNavigationController.h"

#if !TARGET_OS_UIKITFORMAC
#import "DDPFileViewController.h"
#endif

@interface DDPMainViewController ()<UITabBarControllerDelegate>
@end

@implementation DDPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    let arr = [NSMutableArray array];
    if (ddp_appType != DDPAppTypeReview) {
        UINavigationController *homeVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"main_bangumi"] selectImg:[UIImage imageNamed:@"main_bangumi"] rootVC:[[DDPNewHomePagePackageViewController alloc] init] title:nil];
        [arr addObject:homeVC];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
#endif
    
#if !TARGET_OS_UIKITFORMAC
    UINavigationController *fileVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"main_file"] selectImg:[UIImage imageNamed:@"main_file"] rootVC:[[DDPFileViewController alloc] init] title:nil];
    [arr addObject:fileVC];
#endif
    UINavigationController *settingVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"main_mine"] selectImg:[UIImage imageNamed:@"main_mine"] rootVC:[[DDPMineViewController alloc] init] title:nil];
    [arr addObject:settingVC];
    
    
    self.viewControllers = arr;
    
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
#if !DDPAPPTYPE
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 2) {
        [[DDPDownloadManager shareDownloadManager] startObserverTaskInfo];
    }
    else {
        [[DDPDownloadManager shareDownloadManager] stopObserverTaskInfo];
    }
#endif
}

#pragma mark - 私有方法
- (UINavigationController *)navigationControllerWithNormalImg:(UIImage *)normalImg selectImg:(UIImage *)selectImg rootVC:(UIViewController *)rootVC title:(NSString *)title {
    
    normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectImg = [[selectImg imageByTintColor:[UIColor ddp_mainColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title
                                                       image:normalImg
                                               selectedImage:selectImg];
    UINavigationController *navVC = [[DDPBaseNavigationController alloc] initWithRootViewController:rootVC];
    navVC.tabBarItem = item;
    if (ddp_isPad() == NO) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    
    return navVC;
}

@end
