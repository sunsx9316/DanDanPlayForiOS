//
//  SearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SearchViewController.h"
#import <WMPageController.h>
#import "OfficialSearchViewController.h"

@interface SearchViewController ()<UISearchBarDelegate, WMPageControllerDataSource>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) WMPageController *pageController;
@property (strong, nonatomic) NSArray <UIViewController *>*VCArr;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchBar;
    [self.view addSubview:self.pageController.view];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        id vc = self.pageController.currentViewController;
        [vc setKeyword:searchBar.text];
    }
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController * _Nonnull)pageController {
    return self.VCArr.count;
}

- (__kindof UIViewController * _Nonnull)pageController:(WMPageController * _Nonnull)pageController viewControllerAtIndex:(NSInteger)index {
    return self.VCArr[index];
}

- (NSString * _Nonnull)pageController:(WMPageController * _Nonnull)pageController titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"官方搜索";
    }
    return @"网络传输";
}

#pragma mark - 懒加载
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"找不到？试试手动♂搜索";
        _searchBar.returnKeyType = UIReturnKeySearch;
    }
    return _searchBar;
}

- (WMPageController *)pageController {
    if(_pageController == nil) {
        _pageController = [[WMPageController alloc] init];
        _pageController.dataSource = self;
        _pageController.titleColorNormal = [UIColor lightGrayColor];
        _pageController.titleColorSelected = MAIN_COLOR;
        _pageController.titleSizeNormal = 13;
        _pageController.titleSizeSelected = 15;
        _pageController.menuViewContentMargin = 5;
        _pageController.itemMargin = 10;
        _pageController.menuHeight = 35;
        _pageController.menuViewStyle = WMMenuViewStyleLine;
        _pageController.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
        [self addChildViewController:_pageController];
    }
    return _pageController;
}

- (NSArray<UIViewController *> *)VCArr {
    if (_VCArr == nil) {
        OfficialSearchViewController *officialSearchVC = [[OfficialSearchViewController alloc] init];
        officialSearchVC.keyword = _keyword;
        _VCArr = @[officialSearchVC];
    }
    return _VCArr;
}

@end
