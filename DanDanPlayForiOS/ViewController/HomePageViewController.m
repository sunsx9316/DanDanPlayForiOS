//
//  HomePageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageViewController.h"
#import "HomePageItemViewController.h"
#import "JHDefaultPageViewController.h"
#import "WebViewController.h"

#import "MJRefreshHeader+Tools.h"
#import "NSDate+Tools.h"
#import <iCarousel.h>
#import "HomePageBannerView.h"

#define HEAD_VIEW_HEIGHT (self.view.height * .4)

@interface HomePageViewController ()<WMPageControllerDelegate, WMPageControllerDataSource, iCarouselDelegate, iCarouselDataSource>
@property (strong, nonatomic) JHDefaultPageViewController *pageViewController;
@property (strong, nonatomic) JHHomePage *model;
@property (strong, nonatomic) iCarousel *headView;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"新番列表";
    self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeRight;
    
    [RecommedNetManager recommedInfoWithCompletionHandler:^(JHHomePage *responseObject, NSError *error) {
        if (error) {
            [MBProgressHUD showWithError:error];
        }
        else {
            self.model = responseObject;
            [self.pageViewController reloadData];
        }
        
        [self.pageViewController.scrollView.mj_header endRefreshing];
    }];
}

- (void)configLeftItem {
    
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.model.bangumis.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    HomePageItemViewController *vc = [[HomePageItemViewController alloc] init];
    vc.bangumis = [self bangumiCollectionWithIndex:index].collection;
    
    @weakify(self)
    vc.handleBannerCallBack = ^(BOOL isShow) {
        @strongify(self)
        if (!self) return;
        
        if (isShow) {
            if (CGAffineTransformEqualToTransform(self.pageViewController.view.transform, CGAffineTransformIdentity)) {
                [self.headView reloadData];
                [UIView animateWithDuration:0.2 animations:^{
                    self.pageViewController.view.transform = CGAffineTransformMakeTranslation(0, HEAD_VIEW_HEIGHT);
                    self.headView.height = HEAD_VIEW_HEIGHT;
                } completion:^(BOOL finished) {
                    self.timer.fireDate = [NSDate distantPast];
                }];
            }
        }
        else {
            if ((CGAffineTransformEqualToTransform(self.pageViewController.view.transform, CGAffineTransformIdentity)) == NO) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.pageViewController.view.transform = CGAffineTransformIdentity;
                    self.headView.height = 0;
                    [self.headView layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.timer.fireDate = [NSDate distantFuture];
                }];
            }
        }
    };
    
    return vc;
}


- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    JHBangumiCollection *model = [self bangumiCollectionWithIndex:index];
    return model.weekDayStringValue;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.width, NORMAL_SIZE_FONT.lineHeight + 20);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    const float menuViewHeight = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
}

#pragma mark - iCarouselDelegate
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionWrap) {
        return YES;
    }
    if (option == iCarouselOptionOffsetMultiplier) {
        return carousel.numberOfItems > 1 ? value : 0;
    }
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    JHBannerPage *model = self.model.bannerPages[index];
    [[UIApplication sharedApplication] openURL:model.link];
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.model.bannerPages.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)view {
    HomePageBannerView *bannerView = view;
    if (bannerView == nil) {
        bannerView = [[HomePageBannerView alloc] initWithFrame:carousel.bounds];
    }
    
    bannerView.model = self.model.bannerPages[index];
    return bannerView;
}

#pragma mark - 懒加载
- (JHBangumiCollection *)bangumiCollectionWithIndex:(NSInteger)index {
    NSInteger week = [NSDate currentWeekDay];
    if (week < 0 || week > 7) {
        return self.model.bangumis[index];
    }
    index = (index + week) % self.model.bangumis.count;
    return self.model.bangumis[index];
}

#pragma mark - 懒加载
- (JHDefaultPageViewController *)pageViewController {
    if (_pageViewController == nil) {
        _pageViewController = [[JHDefaultPageViewController alloc] init];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

- (iCarousel *)headView {
    if (_headView == nil) {
        _headView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _headView.clipsToBounds = YES;
        _headView.backgroundColor = [UIColor whiteColor];
        _headView.dataSource = self;
        _headView.delegate = self;
        _headView.pagingEnabled = YES;
        _headView.type = iCarouselTypeRotary;
        [self.view addSubview:_headView];
    }
    return _headView;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        @weakify(self)
        _timer = [NSTimer timerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self.headView scrollToItemAtIndex:self.headView.currentItemIndex + 1 duration:1];
        } repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
