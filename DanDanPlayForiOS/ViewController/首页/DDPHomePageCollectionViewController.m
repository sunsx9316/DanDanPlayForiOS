//
//  DDPHomePageCollectionViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomePageCollectionViewController.h"
#import "DDPHomePageItemViewController.h"

#import "DDPDefaultPageViewController.h"
#import "DDPHomeBangumiCollection.h"
#import <UIScrollView+EmptyDataSet.h>
#import "NSDate+Tools.h"

#define HEAD_VIEW_HEIGHT (self.view.height * .4)

@interface DDPHomePageCollectionViewController ()<WMPageControllerDelegate, WMPageControllerDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (strong, nonatomic) DDPDefaultPageViewController *pageViewController;
@property (strong, nonatomic) DDPHomePage *model;
@end

@implementation DDPHomePageCollectionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"时间线";
    
    [self.view addSubview:self.pageViewController.view];
    
    [self requestHomePageWithAnimate:YES completion:^{
        [self.pageViewController reloadData];
        self.pageViewController.menuView.backgroundColor = [UIColor ddp_mainColor];
    }];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.model.bangumis.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    DDPHomePageItemViewController *vc = [[DDPHomePageItemViewController alloc] init];
    vc.bangumis = [self bangumiCollectionWithIndex:index].collection;
    @weakify(vc)
    @weakify(self)
    vc.handleBannerCallBack = ^() {
        @strongify(self)
        if (!self) return;
        
        [self requestHomePageWithAnimate:NO completion:^{
            [weak_vc endRefresh];
        }];
    };
    
    vc.endRefreshCallBack = ^{
        @strongify(self)
        if (!self) return;
        
        [self.pageViewController reloadData];
    };
    
    return vc;
}


- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    DDPHomeBangumiCollection *model = [self bangumiCollectionWithIndex:index];
    return model.weekDayStringValue;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.width, [UIFont ddp_normalSizeFont].lineHeight + 20);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    const float menuViewHeight = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击刷新" attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self requestHomePageWithAnimate:YES completion:^{
        [self.pageViewController reloadData];
    }];
}

#pragma mark - 私有方法
- (DDPHomeBangumiCollection *)bangumiCollectionWithIndex:(NSInteger)index {
    NSInteger week = [NSDate currentWeekDay];
    if (week < 0 || week > 7) {
        return self.model.bangumis[index];
    }
    index = (index + week) % self.model.bangumis.count;
    return self.model.bangumis[index];
}

- (void)requestHomePageWithAnimate:(BOOL)animate
                        completion:(dispatch_block_t)completion {
    if (animate) {
        [self.view showLoading];
    }
    
    [DDPRecommedNetManagerOperation recommedInfoWithCompletionHandler:^(DDPHomePage *responseObject, NSError *error) {
        if (animate) {
            [self.view hideLoading];
        }
        
        if (error) {
            [self.view showWithError:error];
            ((void (*)(id, SEL))(void *) objc_msgSend)((id)self.pageViewController, NSSelectorFromString(@"wm_addScrollView"));
            UIScrollView *view = self.pageViewController.scrollView;
            view.emptyDataSetSource = self;
            view.emptyDataSetDelegate = self;
            view.frame = self.view.bounds;
            [view reloadEmptyDataSet];
        }
        else {
//            [responseObject.bangumis enumerateObjectsUsingBlock:^(DDPHomeBangumiCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [obj.collection sortUsingComparator:^NSComparisonResult(DDPHomeBangumi * _Nonnull obj1, DDPHomeBangumi * _Nonnull obj2) {
//                    return obj2.isFavorite - obj1.isFavorite;
//                }];
//            }];
            self.model = responseObject;
        }
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - 懒加载
- (DDPDefaultPageViewController *)pageViewController {
    if (_pageViewController == nil) {
        _pageViewController = [[DDPDefaultPageViewController alloc] init];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        _pageViewController.menuView.backgroundColor = [UIColor ddp_mainColor];
        _pageViewController.titleColorSelected = [UIColor whiteColor];
        _pageViewController.titleColorNormal = [UIColor ddp_lightGrayColor];
        [self addChildViewController:_pageViewController];
    }
    return _pageViewController;
}


@end
