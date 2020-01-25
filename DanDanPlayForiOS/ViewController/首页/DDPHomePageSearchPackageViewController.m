//
//  DDPHomePageSearchPackageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPHomePageSearchPackageViewController.h"
#import "DDPSearchAnimateViewController.h"
#import "DDPBaseWebViewController.h"
#import "DDPDefaultPageViewController.h"
#import "DDPHomePageSearchViewController.h"
#import "DDPSearchBar.h"
#import "DDPExpandView.h"
#import "CALayer+Animation.h"

@interface DDPHomePageSearchPackageViewController ()<WMPageControllerDataSource, WMPageControllerDelegate, UISearchBarDelegate>
@property (strong, nonatomic) DDPDefaultPageViewController *pageViewController;
@property (strong, nonatomic) NSArray <NSString *>*titleArr;

@property (strong, nonatomic) DDPSearchBar *searchBar;

@property (weak, nonatomic) DDPHomePageSearchViewController *dmhySearchResultVC;
@end

@implementation DDPHomePageSearchPackageViewController

- (instancetype)initWithKeyword:(NSString *)keyword {
    if (self = [super init]) {
        self.searchBar.text = keyword;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTitleView];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    [UIView performWithoutAnimation:^{
        if (self.searchBar.text.length == 0) {
            [self.searchBar becomeFirstResponder];            
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.pageViewController.view.frame = self.view.bounds;
}

- (void)touchLeftItem:(UIButton *)button {
    [self.searchBar resignFirstResponder];
    [super touchLeftItem:button];
}

- (void)configTitleView {
    DDPExpandView *searchBarHolderView = [[DDPExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    [searchBarHolderView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_offset(0);
        make.trailing.mas_offset(0);
        make.top.bottom.mas_equalTo(0);
    }];
    self.navigationItem.titleView = searchBarHolderView;
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_browser"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)sender {
    if (self.searchBar.text.length == 0) {
        [self.searchBar.layer shake];
        [self.view showWithText:@"还没输入关键字哦~"];
        return;
    }
    
    NSString *link = [NSString stringWithFormat:@"https://share.dmhy.org/topics/list?keyword=%@", [self.searchBar.text stringByURLEncode]];
    [self.searchBar resignFirstResponder];

#if DDPAPPTYPEISMAC
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:@{} completionHandler:nil];
#else
    DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:[NSURL URLWithString:link]];
    @weakify(self)
    vc.clickMagnetCallBack = ^(NSString *url) {
        @strongify(self)
        if (!self) return;
        
        [self.dmhySearchResultVC downloadVideoWithMagnet:url];
    };
    [self.navigationController pushViewController:vc animated:YES];
#endif
}

#pragma mark - WMPageControllerDataSource
- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    let frame = [self pageController:pageController preferredFrameForMenuView:pageController.menuView];
    
    return CGRectMake(0, CGRectGetMaxY(frame), self.view.width, self.view.height - frame.size.height);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.width, 44);
}

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleArr.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (index == 0) {
        let vc = [[DDPSearchAnimateViewController alloc] init];
        vc.keyword = self.searchBar.text;
        return vc;
    }
    
    DDPHomePageSearchViewController *vc = [[DDPHomePageSearchViewController alloc] init];
    let model = [[DDPDMHYSearchConfig alloc] init];
    model.keyword = self.searchBar.text;
    vc.config = model;
    self.dmhySearchResultVC = vc;
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titleArr[index];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    
    [self.pageViewController reloadData];
}


#pragma mark - 懒加载
- (DDPDefaultPageViewController *)pageViewController {
    if (_pageViewController == nil) {
        _pageViewController = [[DDPDefaultPageViewController alloc] init];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }
    return _pageViewController;
}

- (NSArray<NSString *> *)titleArr {
    if (_titleArr == nil) {
        _titleArr = @[@"相关番剧", @"资源搜索"];
    }
    return _titleArr;
}

- (DDPSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[DDPSearchBar alloc] init];
        _searchBar.placeholder = @"搜索资源";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

@end
