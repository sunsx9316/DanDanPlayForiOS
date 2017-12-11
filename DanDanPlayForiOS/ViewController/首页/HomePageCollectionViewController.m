//
//  HomePageCollectionViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageCollectionViewController.h"
#import "JHDefaultPageViewController.h"

@interface HomePageCollectionViewController ()<WMPageControllerDataSource, WMPageControllerDelegate>
@property (strong, nonatomic) JHDefaultPageViewController *pageViewController;
@end

@implementation HomePageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - WMPageControllerDataSource
//- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
//    
//}
//
//- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
//    
//}
//
//- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
//    
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
//    
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
//    
//}

#pragma mark - 懒加载
- (JHDefaultPageViewController *)pageViewController {
    if (_pageViewController == nil) {
        _pageViewController = [[JHDefaultPageViewController alloc] init];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        [self addChildViewController:_pageViewController];
    }
    return _pageViewController;
}

@end
