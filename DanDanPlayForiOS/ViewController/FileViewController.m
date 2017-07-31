//
//  FileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileViewController.h"
#import "JHDefaultPageViewController.h"
#import "LocalFileViewController.h"
#import "SMBViewController.h"
#import "HTTPServerViewController.h"
#import "HelpViewController.h"

#import "JHEdgeButton.h"

@interface FileViewController ()<WMPageControllerDataSource, WMPageControllerDelegate>
@property (strong, nonatomic) JHDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSString *>*titleArr;
@property (strong, nonatomic) UIButton *httpButton;
@property (strong, nonatomic) UIButton *helpButton;
@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    self.navigationItem.title = @"文件";
    
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
        self.httpButton.alpha = 1 - alpha;
        self.helpButton.alpha = alpha;
    }
}

#pragma mark - 懒加载

- (void)configLeftItem {
    
}

- (void)configRightItem {
    UIView *holdView = [[UIView alloc] initWithFrame:self.httpButton.bounds];
    [holdView addSubview:self.httpButton];
    [holdView addSubview:self.helpButton];
    self.helpButton.alpha = 0;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:holdView];
    self.navigationItem.rightBarButtonItem = item;
}

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

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleArr.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (index == 0) {
        return [[LocalFileViewController alloc] init];
    }
    return [[SMBViewController alloc] init];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titleArr[index];
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
        [self.view addSubview:_pageController.view];
    }
    return _pageController;
}

- (UIButton *)httpButton {
    if (_httpButton == nil) {
        _httpButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_httpButton addTarget:self action:@selector(touchHttpButton:) forControlEvents:UIControlEventTouchUpInside];
        [_httpButton setBackgroundImage:[UIImage imageNamed:@"add_file"] forState:UIControlStateNormal];
    }
    return _httpButton;
}

- (UIButton *)helpButton {
    if (_helpButton == nil) {
        _helpButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_helpButton addTarget:self action:@selector(touchHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [_helpButton setBackgroundImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    }
    return _helpButton;
}

- (NSArray<NSString *> *)titleArr {
    if (_titleArr == nil) {
        _titleArr = @[@"本机文件", @"远程设备"];
    }
    return _titleArr;
}

@end
