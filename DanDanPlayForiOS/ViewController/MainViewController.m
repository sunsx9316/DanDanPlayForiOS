//
//  MainViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MainViewController.h"

#import "FileViewController.h"
#import "SettingViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *fileVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"home_home_tab"] selectImg:[UIImage imageNamed:@"home_home_tab_s"] rootVC:[[FileViewController alloc] init] title:@"首页"];
    UINavigationController *settingVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"home_category_tab"] selectImg:[UIImage imageNamed:@"home_category_tab_s"] rootVC:[[SettingViewController alloc] init] title:@"分区"];
    
    self.viewControllers = @[fileVC, settingVC];
    self.tabBar.translucent = NO;
}


- (UINavigationController *)navigationControllerWithNormalImg:(UIImage *)normalImg selectImg:(UIImage *)selectImg rootVC:(UIViewController *)rootVC title:(NSString *)title {
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:normalImg selectedImage:[[selectImg imageByTintColor:MAIN_COLOR] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    navVC.tabBarItem = item;
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    return navVC;
}

@end
