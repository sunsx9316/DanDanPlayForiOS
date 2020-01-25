//
//  DDPSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSearchViewController.h"
#import "DDPDefaultPageViewController.h"
#import "DDPOfficialSearchViewController.h"
#import "DDPBiliBiliSearchViewController.h"
#import "DDPExpandView.h"
#import "DDPSearchBar.h"

@interface DDPSearchViewController ()<UISearchBarDelegate, WMPageControllerDataSource, WMPageControllerDelegate>
@property (strong, nonatomic) DDPSearchBar *searchBar;
@property (strong, nonatomic) DDPDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSString *>*titleArr;
@end

@implementation DDPSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTitleView];
    [self.pageController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        self.keyword = searchBar.text;
        [self.searchBar endEditing:YES];
        [self.pageController reloadData];
//        id vc = self.pageController.currentViewController;
//        [vc setKeyword:searchBar.text];
    }
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleArr.count;
}

- (__kindof UIViewController * _Nonnull)pageController:(WMPageController * _Nonnull)pageController viewControllerAtIndex:(NSInteger)index {
//    if (index == 0) {
        let vc = [[DDPOfficialSearchViewController alloc] init];
        vc.keyword = _keyword;
        vc.model = _model;
        return vc;
//    }
//
//    let vc = [[DDPBiliBiliSearchViewController alloc] init];
//    vc.keyword = _keyword;
//    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titleArr[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.width, [UIFont ddp_normalSizeFont].lineHeight + 20);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    const float menuViewHeight = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
}

#pragma mark - 私有方法
- (void)configTitleView {
    DDPExpandView *view = [[DDPExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
    [view addSubview:self.searchBar];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.navigationItem.titleView = view;
}

#pragma mark - 懒加载
- (DDPSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[DDPSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"试试手动♂搜索";
        _searchBar.text = self.keyword;
        _searchBar.returnKeyType = UIReturnKeySearch;
    }
    return _searchBar;
}

- (DDPDefaultPageViewController *)pageController {
    if(_pageController == nil) {
        _pageController = [[DDPDefaultPageViewController alloc] init];
        _pageController.dataSource = self;
        _pageController.delegate = self;
        [self addChildViewController:_pageController];
        [self.view addSubview:_pageController.view];
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
