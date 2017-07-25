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

#import "JHEdgeButton.h"

@interface FileViewController ()<WMPageControllerDataSource, WMPageControllerDelegate>
@property (strong, nonatomic) JHDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <UIViewController *>*VCArr;
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
        float alpha = 1 - (offset.x / self.view.width);
        self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = alpha == 1;
        self.navigationItem.rightBarButtonItem.customView.alpha = alpha;
    }
}

#pragma mark - 懒加载

- (void)configLeftItem {
    
}

- (void)configRightItem {
    JHEdgeButton *backButton = [[JHEdgeButton alloc] init];
    backButton.inset = CGSizeMake(10, 10);
    [backButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"add_file"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)touchRightItem:(UIButton *)button {
    HTTPServerViewController *vc = [[HTTPServerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
        return @"本机文件";
    }
    return @"远程设备";
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

- (NSArray<UIViewController *> *)VCArr {
    if (_VCArr == nil) {
        _VCArr = @[[[LocalFileViewController alloc] init], [[SMBViewController alloc] init]];
    }
    return _VCArr;
}

@end
