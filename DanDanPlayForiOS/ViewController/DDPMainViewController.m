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
#import "DDPTabBar.h"

#if !DDPAPPTYPEISMAC
#import "DDPFileViewController.h"
#endif

@interface DDPMainViewController ()<UITabBarControllerDelegate>
@end

@implementation DDPMainViewController

+ (NSArray<DDPMainVCItem *> *)items {
    static dispatch_once_t onceToken;
    static NSArray<DDPMainVCItem *>*_items = nil;
    dispatch_once(&onceToken, ^{
        let arr = [NSMutableArray array];
        if (ddp_appType != DDPAppTypeReview) {
            DDPMainVCItem *item = [[DDPMainVCItem alloc] init];
            item.normalImage = [UIImage imageNamed:@"main_bangumi"];
            item.selectedImage = [UIImage imageNamed:@"main_bangumi"];
            item.name = @"首页";
            item.vcClassName = [DDPNewHomePagePackageViewController className];
            [arr addObject:item];
        }
#if !DDPAPPTYPEISMAC
        {
            DDPMainVCItem *item = [[DDPMainVCItem alloc] init];
            item.normalImage = [UIImage imageNamed:@"main_file"];
            item.selectedImage = [UIImage imageNamed:@"main_file"];
            item.name = @"文件";
            item.vcClassName = [DDPFileViewController className];
            [arr addObject:item];
        }
#endif
        
        {
            DDPMainVCItem *item = [[DDPMainVCItem alloc] init];
            item.normalImage = [UIImage imageNamed:@"main_mine"];
            item.selectedImage = [UIImage imageNamed:@"main_mine"];
            item.name = @"我的";
            item.vcClassName = [DDPMineViewController className];
            [arr addObject:item];
        }
        
        _items = arr;
    });
    return _items;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (ddp_appType == DDPAppTypeToMac) {
            object_setClass(self.tabBar, [DDPTabBar class]);            
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    let items = [self.class items];
    let arr = [NSMutableArray arrayWithCapacity:items.count];
    
    [items enumerateObjectsUsingBlock:^(DDPMainVCItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UINavigationController *vc = [self navigationControllerWithNormalImg:obj.normalImage selectImg:obj.selectedImage rootVC:[[NSClassFromString(obj.vcClassName) alloc] init] title:nil];
        [arr addObject:vc];
    }];
    
    self.viewControllers = arr;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
#endif
    
    if (ddp_appType == DDPAppTypeToMac) {
        self.tabBar.alpha = 0;
    } else {
        self.tabBar.translucent = NO;
    }
    
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
