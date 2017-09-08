//
//  SearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SearchViewController.h"
#import "JHDefaultPageViewController.h"
#import "OfficialSearchViewController.h"

@interface SearchViewController ()<UISearchBarDelegate, WMPageControllerDataSource>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) JHDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSString *>*titleArr;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchBar;
    [self.view addSubview:self.pageController.view];
}

- (void)configLeftItem {
    [super configLeftItem];
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceBar.width = 15;
    self.navigationItem.leftBarButtonItems = @[item, spaceBar];
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        [self.searchBar endEditing:YES];
        id vc = self.pageController.currentViewController;
        [vc setKeyword:searchBar.text];
    }
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController * _Nonnull)pageController {
    return self.titleArr.count;
}

- (__kindof UIViewController * _Nonnull)pageController:(WMPageController * _Nonnull)pageController viewControllerAtIndex:(NSInteger)index {
    OfficialSearchViewController *officialSearchVC = [[OfficialSearchViewController alloc] init];
    officialSearchVC.keyword = _keyword;
    officialSearchVC.model = _model;
    return officialSearchVC;
}

- (NSString * _Nonnull)pageController:(WMPageController * _Nonnull)pageController titleAtIndex:(NSInteger)index {
    return self.titleArr[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.width, NORMAL_SIZE_FONT.lineHeight + 20);
}

#pragma mark - 懒加载
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"找不到？试试手动♂搜索";
        _searchBar.returnKeyType = UIReturnKeySearch;
    }
    return _searchBar;
}

- (JHDefaultPageViewController *)pageController {
    if(_pageController == nil) {
        _pageController = [[JHDefaultPageViewController alloc] init];
        _pageController.dataSource = self;
        [self addChildViewController:_pageController];
    }
    return _pageController;
}

- (NSArray<NSString *> *)titleArr {
    if (_titleArr == nil) {
        _titleArr = @[@"官方搜索"];
    }
    return _titleArr;
}


@end
