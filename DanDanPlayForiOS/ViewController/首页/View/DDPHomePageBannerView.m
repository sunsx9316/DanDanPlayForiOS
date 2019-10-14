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

#import <iCarousel/iCarousel.h>

#define SCROLL_TIME_INTERVAL 5

@interface DDPHomePageBannerView ()<iCarouselDelegate, iCarouselDataSource>
@property (strong, nonatomic) iCarousel *scrollView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSTimer *reloadTimer;
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
            if (ddp_appType == DDPAppTypeToMac) {
                make.right.mas_offset(-15);
            } else {
                make.right.mas_offset(-5);
            }
            make.top.mas_offset(-5);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
#if DDPAPPTYPEISMAC
    [self.reloadTimer invalidate];
    @weakify(self)
    self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 block:^(NSTimer * _Nonnull timer) {
        @strongify(self)
        if (!self) return;
        
        [self.scrollView reloadData];
    } repeats:NO];
#endif
}

- (void)setModels:(NSArray<DDPNewBanner *> *)models {
    _models = models;
    [self.timer invalidate];
    
    [self.scrollView reloadData];
    self.pageControl.numberOfPages = _models.count;
    @weakify(self)
    self.timer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_TIME_INTERVAL block:^(NSTimer * _Nonnull timer) {
        @strongify(self)
        if (!self) return;
        
        [self.scrollView scrollToItemAtIndex:self.scrollView.currentItemIndex + 1 duration:0.8];
    } repeats:YES];
}

#pragma mark - Private Method
- (void)reloadDate {
    [self.scrollView reloadData];
}


#pragma mark - iCarouselDelegate
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionWrap) {
        return YES;
    }
    
    if (option == iCarouselOptionOffsetMultiplier) {
        return carousel.numberOfItems > 1 ? value : 0;
    }
    
    if (option == iCarouselOptionCount) {
        if (ddp_appType == DDPAppTypeToMac) {
            return 5;
        }
        return value;
    }
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    self.pageControl.currentPage = carousel.currentItemIndex;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    if (index != carousel.currentItemIndex) {
        [carousel scrollToItemAtIndex:index animated:YES];
        return;
    }
    
    let model = self.models[index];
    if (ddp_appType == DDPAppTypeToMac) {
        [[UIApplication sharedApplication] openURL:model.url options:@{} completionHandler:nil];
    } else {
        DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:model.url];
        vc.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    if (ddp_appType == DDPAppTypeToMac) {
        return floor(carousel.width / 2);
    } else {
        return carousel.width;
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:SCROLL_TIME_INTERVAL];
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.models.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)view {
    DDPHomePageBannerCollectionViewCell *bannerView = view;
    CGRect frame = CGRectZero;
    
    if (ddp_appType == DDPAppTypeToMac) {
        frame = CGRectMake(0, 10, floor(carousel.width / 2), carousel.height - 20);
    } else {
        frame = carousel.bounds;
    }
    
    if (bannerView == nil) {
        bannerView = [[DDPHomePageBannerCollectionViewCell alloc] initWithFrame:frame];
    }
    
    bannerView.frame = frame;
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
        if (ddp_appType == DDPAppTypeToMac) {
            _scrollView.type = iCarouselTypeRotary;
            _scrollView.perspective = -1.0 / 1500.0;
        } else {
            _scrollView.type = iCarouselTypeLinear;
        }
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.defersCurrentPageDisplay = YES;
        _pageControl.currentPageIndicatorTintColor = [UIColor ddp_mainColor];
        if (ddp_appType == DDPAppTypeToMac) {
            _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
        } else {
            _pageControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
            _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        }
    }
    return _pageControl;
}

@end
