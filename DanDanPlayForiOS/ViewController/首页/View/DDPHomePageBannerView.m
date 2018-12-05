//
//  DDPHomePageBannerView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/5.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPHomePageBannerView.h"
#import "DDPBaseCollectionView.h"
#import "DDPHomePageBannerCollectionViewCell.h"
#import "DDPBaseWebViewController.h"

#import <iCarousel.h>

@interface DDPHomePageBannerView ()<iCarouselDelegate, iCarouselDataSource>
@property (strong, nonatomic) iCarousel *scrollView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation DDPHomePageBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
        
        [self addSubview:self.scrollView];
        
        [self addSubview:self.pageControl];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
            make.height.mas_equalTo(HOME_BANNER_VIEW_HEIGHT);
        }];
        
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-5);
            make.top.mas_offset(-5);
        }];
    }
    return self;
}

- (void)setModels:(NSArray<DDPNewBanner *> *)models {
    _models = models;
    [self.timer invalidate];
    
    [self.scrollView reloadData];
    self.pageControl.numberOfPages = _models.count;
    
    @weakify(self)
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
        @strongify(self)
        if (!self) return;
        
        [self.scrollView scrollToItemAtIndex:self.scrollView.currentItemIndex + 1 duration:0.8];
    } repeats:YES];
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
    self.pageControl.currentPage = carousel.currentItemIndex;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    let model = self.models[index];
    DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:model.url];
    vc.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.models.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)view {
    DDPHomePageBannerCollectionViewCell *bannerView = view;
    if (bannerView == nil) {
        bannerView = [[DDPHomePageBannerCollectionViewCell alloc] initWithFrame:carousel.bounds];
    }
    
    bannerView.banner = self.models[index];
    return bannerView;
}

#pragma mark - 懒加载
- (iCarousel *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, HOME_BANNER_VIEW_HEIGHT)];
        _scrollView.clipsToBounds = YES;
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.type = iCarouselTypeLinear;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.defersCurrentPageDisplay = YES;
        _pageControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
        _pageControl.currentPageIndicatorTintColor = [UIColor ddp_mainColor];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    }
    return _pageControl;
}

@end
