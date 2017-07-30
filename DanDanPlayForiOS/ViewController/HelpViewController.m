//
//  HelpViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/30.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HelpViewController.h"
#import "JHDefaultPageViewController.h"
#import "WebViewController.h"

@interface HelpViewController ()<WMPageControllerDataSource, WMPageControllerDelegate>
@property (strong, nonatomic) JHDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <UIViewController *>*VCArr;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"帮助";
    [self.view addSubview:self.pageController.view];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.VCArr.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    return self.VCArr[index];
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
    return CGRectMake(0, 0, self.view.width, NORMAL_SIZE_FONT.lineHeight + 20);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    const float menuViewHeight = NORMAL_SIZE_FONT.lineHeight + 20;
    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
}

#pragma mark - 懒加载
- (JHDefaultPageViewController *)pageController {
    if (_pageController == nil) {
        _pageController = [[JHDefaultPageViewController alloc] init];
        _pageController.dataSource = self;
        _pageController.delegate = self;
        [self addChildViewController:_pageController];
    }
    return _pageController;
}

- (NSArray<UIViewController *> *)VCArr {
    if (_VCArr == nil) {
        WebViewController *windowsVC = [[WebViewController alloc] init];
        windowsVC.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"windows" ofType:@"html" inDirectory:@"course"]];
        windowsVC.showProgressView = NO;
        
        WebViewController *macVC = [[WebViewController alloc] init];
        macVC.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mac" ofType:@"html" inDirectory:@"course"]];
        macVC.showProgressView = NO;
        
        WebViewController *routerVC = [[WebViewController alloc] init];
        routerVC.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"router" ofType:@"html" inDirectory:@"course"]];
        routerVC.showProgressView = NO;
        
        _VCArr = @[windowsVC, macVC, routerVC];
    }
    return _VCArr;
}
@end
