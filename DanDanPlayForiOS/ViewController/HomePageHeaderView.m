//
//  HomePageHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageHeaderView.h"
#import "HomePageBannerView.h"
#import <iCarousel.h>

@interface HomePageHeaderView ()<iCarouselDelegate, iCarouselDataSource>
@property (strong, nonatomic) iCarousel *scrollView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation HomePageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(-MENU_VIEW_HEIGHT);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(BANNER_HEIGHT);
        }];
        
        CGFloat width = (kScreenWidth - 100) / 2;
        
        [self.attionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(40);
            make.bottom.mas_offset(-10);
            make.centerX.mas_offset(-(width / 2 + 10));
        }];
        
        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.attionButton);
            make.bottom.mas_offset(-10);
            make.centerX.mas_offset(width / 2 + 10);
        }];
    }
    return self;
}

- (void)setDataSource:(NSArray<JHBannerPage *> *)dataSource {
    _dataSource = dataSource;
    [self.scrollView reloadData];
    self.timer.fireDate = [NSDate distantPast];
}

- (UIButton *)attionButton {
    if (_attionButton == nil) {
        _attionButton = [[UIButton alloc] init];
        [_attionButton setImage:[[UIImage imageNamed:@"home_attention"] imageByTintColor:MAIN_COLOR] forState:UIControlStateNormal];
        _attionButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_attionButton setTitle:@"我的关注" forState:UIControlStateNormal];
        [_attionButton setBackgroundImage:[UIImage imageNamed:@"home_bangumi_group_bg"] forState:UIControlStateNormal];
        [_attionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _attionButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//        _attionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//        _attionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
        [self addSubview:_attionButton];
    }
    return _attionButton;
}

- (UIButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[UIButton alloc] init];
        [_searchButton setImage:[[UIImage imageNamed:@"home_search"] imageByTintColor:MAIN_COLOR] forState:UIControlStateNormal];
        _searchButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_searchButton setTitle:@"搜索资源" forState:UIControlStateNormal];
        [_searchButton setBackgroundImage:[UIImage imageNamed:@"home_bangumi_group_bg"] forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [self addSubview:_searchButton];
    }
    return _searchButton;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (point.y < 0) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
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
    JHBannerPage *task = _dataSource[index];
    if (self.didSelctedModelCallBack) {
        self.didSelctedModelCallBack(task);
    }
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.dataSource.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)view {
    HomePageBannerView *bannerView = view;
    if (bannerView == nil) {
        bannerView = [[HomePageBannerView alloc] initWithFrame:carousel.bounds];
    }
    
    bannerView.model = self.dataSource[index];
    return bannerView;
}

#pragma mark - 懒加载
- (iCarousel *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, BANNER_HEIGHT)];
        _scrollView.clipsToBounds = YES;
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.type = iCarouselTypeRotary;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.defersCurrentPageDisplay = YES;
        _pageControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
        [self addSubview:_pageControl ];
    }
    return _pageControl;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        @weakify(self)
        _timer = [NSTimer timerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self.scrollView scrollToItemAtIndex:self.scrollView.currentItemIndex + 1 duration:1];
        } repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
