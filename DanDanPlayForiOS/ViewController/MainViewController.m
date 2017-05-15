//
//  MainViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MainViewController.h"
#import "BaseNavigationController.h"
#import "LocalFileViewController.h"
#import "SettingViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *fileVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"file"] selectImg:[UIImage imageNamed:@"file"] rootVC:[[LocalFileViewController alloc] init] title:nil];
    UINavigationController *settingVC = [self navigationControllerWithNormalImg:[UIImage imageNamed:@"setting"] selectImg:[UIImage imageNamed:@"setting"] rootVC:[[SettingViewController alloc] init] title:nil];
    
    self.viewControllers = @[fileVC, settingVC];
    self.tabBar.translucent = NO;
}


- (UINavigationController *)navigationControllerWithNormalImg:(UIImage *)normalImg selectImg:(UIImage *)selectImg rootVC:(UIViewController *)rootVC title:(NSString *)title {
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:normalImg selectedImage:[[selectImg imageByTintColor:MAIN_COLOR] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:rootVC];
    navVC.tabBarItem = item;
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    return navVC;
}

@end
