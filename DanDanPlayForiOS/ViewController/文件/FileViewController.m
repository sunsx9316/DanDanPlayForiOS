//
//  FileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileViewController.h"
#import "JHDefaultPageViewController.h"
#import "SMBViewController.h"
#import "HTTPServerViewController.h"
#import "HelpViewController.h"
#import "FileManagerViewController.h"
#import "FileManagerNavigationController.h"
#import "LinkFileManagerNavigationController.h"
#import "LinkFileManagerViewController.h"
#import "QRScanerViewController.h"

#import "JHEdgeButton.h"
#import "FileManagerSearchView.h"
#import "JHExpandView.h"

@interface FileViewController ()<WMPageControllerDataSource, WMPageControllerDelegate, UISearchBarDelegate, FileManagerSearchViewDelegate>
@property (strong, nonatomic) JHDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSString *>*titleArr;
@property (strong, nonatomic) UIButton *httpButton;
@property (strong, nonatomic) UIButton *helpButton;
@property (strong, nonatomic) UIButton *qrCodeButton;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) FileManagerSearchView *searchView;
@end

@implementation FileViewController
{
    __weak FileManagerViewController *_fileManagerViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    [self configTitleView];
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self.pageController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    //监听滚动
    [self.pageController.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.pageController.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        float alpha = offset.x / self.view.width;
        
        if (alpha > 1) {
            alpha = alpha - 1;
            self.httpButton.alpha = 0;
            self.helpButton.alpha = 1 - alpha;
            self.qrCodeButton.alpha = alpha;
            self.searchBar.alpha = 0;
        }
        else {
            self.qrCodeButton.alpha = 0;
            self.httpButton.alpha = 1 - alpha;
            self.helpButton.alpha = alpha;
            self.searchBar.alpha = 1 - alpha;
        }
    }
}

#pragma mark - 私有方法
- (void)configLeftItem {
    
}

- (void)configRightItem {
    UIView *holdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [holdView addSubview:self.httpButton];
    [holdView addSubview:self.helpButton];
    [holdView addSubview:self.qrCodeButton];
    
    [self.httpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.qrCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.helpButton.alpha = 0;
    self.qrCodeButton.alpha = 0;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:holdView];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)configTitleView {
    JHExpandView *searchBarHolderView = [[JHExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    [searchBarHolderView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_offset(10);
        make.trailing.mas_offset(-10);
        make.top.bottom.mas_equalTo(0);
    }];
    self.navigationItem.titleView = searchBarHolderView;
}

#pragma mark - 懒加载
- (void)touchHttpButton:(UIButton *)button {
    HTTPServerViewController *vc = [[HTTPServerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchHelpButton:(UIButton *)button {
    HelpViewController *vc = [[HelpViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchQRCodeButton:(UIButton *)button {
    QRScanerViewController *vc = [[QRScanerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleArr.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (index == 0) {
        FileManagerViewController *vc = [[FileManagerViewController alloc] init];
        vc.file = jh_getANewRootFile();
        _fileManagerViewController = vc;
        FileManagerNavigationController *nav = [[FileManagerNavigationController alloc] initWithRootViewController:vc];
        return nav;
    }
    else if (index == 1) {
        return [[SMBViewController alloc] init];
    }

    LinkFileManagerViewController *vc = [[LinkFileManagerViewController alloc] init];
    vc.file = jh_getANewLinkRootFile();
    LinkFileManagerNavigationController *nav = [[LinkFileManagerNavigationController alloc] initWithRootViewController:vc];
    
    return nav;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titleArr[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, self.navigationController.navigationBar.bottom, self.view.width, NORMAL_SIZE_FONT.lineHeight + 20);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    const float menuViewHeight = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchView show];
    return NO;
}

#pragma mark - FileManagerSearchViewDelegate
- (void)searchView:(FileManagerSearchView *)searchView didSelectedFile:(JHFile *)file {
    [_fileManagerViewController matchFile:file];
}

#pragma mark - 懒加载
- (JHDefaultPageViewController *)pageController {
    if (_pageController == nil) {
        _pageController = [[JHDefaultPageViewController alloc] init];
        _pageController.dataSource = self;
        _pageController.delegate = self;
        [self addChildViewController:_pageController];
        [self.view addSubview:_pageController.view];
    }
    return _pageController;
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索文件名";
        _searchBar.delegate = self;
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.tintColor = [UIColor whiteColor];
    }
    return _searchBar;
}

- (UIButton *)httpButton {
    if (_httpButton == nil) {
        _httpButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_httpButton addTarget:self action:@selector(touchHttpButton:) forControlEvents:UIControlEventTouchUpInside];
        [_httpButton setImage:[UIImage imageNamed:@"file_add_file"] forState:UIControlStateNormal];
    }
    return _httpButton;
}

- (UIButton *)helpButton {
    if (_helpButton == nil) {
        _helpButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_helpButton addTarget:self action:@selector(touchHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [_helpButton setImage:[UIImage imageNamed:@"file_help"] forState:UIControlStateNormal];
    }
    return _helpButton;
}

- (UIButton *)qrCodeButton {
    if (_qrCodeButton == nil) {
        _qrCodeButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_qrCodeButton addTarget:self action:@selector(touchQRCodeButton:) forControlEvents:UIControlEventTouchUpInside];
        [_qrCodeButton setImage:[UIImage imageNamed:@"file_qr_code"] forState:UIControlStateNormal];
    }
    return _qrCodeButton;
}

- (FileManagerSearchView *)searchView {
    if (_searchView == nil) {
        _searchView = [[FileManagerSearchView alloc] init];
        _searchView.delegete = self;
    }
    return _searchView;
}

- (NSArray<NSString *> *)titleArr {
    if (_titleArr == nil) {
        _titleArr = @[@"本机文件", @"远程设备", @"电脑端"];
    }
    return _titleArr;
}

@end
