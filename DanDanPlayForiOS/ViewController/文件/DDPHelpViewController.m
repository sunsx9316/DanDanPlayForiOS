//
//  DDPHelpViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/30.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHelpViewController.h"
#import "DDPDefaultPageViewController.h"
#import "DDPBaseWebViewController.h"

@interface DDPHelpViewController ()<WMPageControllerDataSource, WMPageControllerDelegate>
@property (strong, nonatomic) DDPDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSURL *>*URLArr;
@end

@implementation DDPHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"帮助";
    [self.view addSubview:self.pageController.view];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.URLArr.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:self.URLArr[index]];
    vc.showProgressView = NO;
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"windows";
    }
    
    if (index == 1) {
        return @"Mac OS";
    }
    
    return @"路由器";
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.width, [UIFont ddp_normalSizeFont].lineHeight + 20);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    const float menuViewHeight = [UIFont ddp_normalSizeFont].lineHeight + 20;
    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
}

#pragma mark - 懒加载
- (DDPDefaultPageViewController *)pageController {
    if (_pageController == nil) {
        _pageController = [[DDPDefaultPageViewController alloc] init];
        _pageController.dataSource = self;
        _pageController.delegate = self;
        [self addChildViewController:_pageController];
    }
    return _pageController;
}

- (NSArray<NSURL *> *)URLArr {
    if (_URLArr == nil) {
        _URLArr = @[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"windows" ofType:@"html" inDirectory:@"course"]], [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mac" ofType:@"html" inDirectory:@"course"]], [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"router" ofType:@"html" inDirectory:@"course"]]];
    }
    return _URLArr;
}

//- (NSArray<UIViewController *> *)VCArr {
//    if (_VCArr == nil) {
//        DDPBaseWebViewController *windowsVC = [[DDPBaseWebViewController alloc] init];
//        windowsVC.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"windows" ofType:@"html" inDirectory:@"course"]];
//        windowsVC.showProgressView = NO;
//        
//        DDPBaseWebViewController *macVC = [[DDPBaseWebViewController alloc] init];
//        macVC.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mac" ofType:@"html" inDirectory:@"course"]];
//        macVC.showProgressView = NO;
//        
//        DDPBaseWebViewController *routerVC = [[DDPBaseWebViewController alloc] init];
//        routerVC.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"router" ofType:@"html" inDirectory:@"course"]];
//        routerVC.showProgressView = NO;
//        
//        _VCArr = @[windowsVC, macVC, routerVC];
//    }
//    return _VCArr;
//}
@end
