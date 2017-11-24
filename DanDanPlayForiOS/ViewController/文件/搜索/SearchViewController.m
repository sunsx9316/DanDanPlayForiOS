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
#import "JHExpandView.h"
#import "JHSearchBar.h"

@interface SearchViewController ()<UISearchBarDelegate, WMPageControllerDataSource>
@property (strong, nonatomic) JHSearchBar *searchBar;
@property (strong, nonatomic) JHDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSString *>*titleArr;
@end

@implementation SearchViewController

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

#pragma mark - 私有方法
- (void)configTitleView {
    JHExpandView *view = [[JHExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
    [view addSubview:self.searchBar];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.navigationItem.titleView = view;
}

#pragma mark - 懒加载
- (JHSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[JHSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"试试手动♂搜索";
        _searchBar.returnKeyType = UIReturnKeySearch;
        _searchBar.textField.font = NORMAL_SIZE_FONT;
        _searchBar.tintColor = MAIN_COLOR;
        _searchBar.backgroundColor = [UIColor clearColor];
    }
    return _searchBar;
}

- (JHDefaultPageViewController *)pageController {
    if(_pageController == nil) {
        _pageController = [[JHDefaultPageViewController alloc] init];
        _pageController.dataSource = self;
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
