//
//  HomePageHeaderTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageHeaderTableViewCell.h"
#import "DDPHomePageBannerCollectionViewCell.h"
#import <iCarousel.h>

@interface HomePageHeaderTableViewCell ()<iCarouselDelegate, iCarouselDataSource>
@property (strong, nonatomic) iCarousel *scrollView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIPageControl *pageControl;
//@property (strong, nonatomic) UIButton *timeLineButton;
//@property (strong, nonatomic) UIButton *searchButton;
@end

@implementation HomePageHeaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.scrollView];
//        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.right.bottom.mas_equalTo(0);
////            make.height.mas_equalTo(BANNER_HEIGHT);
//        }];
        
//        CGFloat width = (kScreenWidth - 100) / 2;
        
//        [self.timeLineButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(width);
//            make.height.mas_equalTo(40);
//            make.bottom.mas_offset(-10);
//            make.centerX.mas_offset(-(width / 2 + 10));
//        }];
//
//        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(self.timeLineButton);
//            make.bottom.mas_offset(-10);
//            make.centerX.mas_offset(width / 2 + 10);
//        }];
        
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-5);
            make.top.mas_offset(-5);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentView.frame = self.bounds;
}

- (void)setDataSource:(NSArray<DDPNewBanner *> *)dataSource {
    _dataSource = dataSource;
    [self.scrollView reloadData];
    self.pageControl.numberOfPages = _dataSource.count;
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
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
    let task = _dataSource[index];
    if (self.didSelctedModelCallBack) {
        self.didSelctedModelCallBack(task);
    }
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.dataSource.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)view {
    DDPHomePageBannerCollectionViewCell *bannerView = view;
    if (bannerView == nil) {
        bannerView = [[DDPHomePageBannerCollectionViewCell alloc] initWithFrame:carousel.bounds];
    }
    
    bannerView.banner = self.dataSource[index];
    return bannerView;
}

#pragma mark - 私有方法
- (void)touchTimeLineButton:(UIButton *)sender {
    if (self.touchTimeLineButtonCallBack) {
        self.touchTimeLineButtonCallBack();
    }
}

- (void)touchSearchButton:(UIButton *)sender {
    if (self.touchSearchButtonCallBack) {
        self.touchSearchButtonCallBack();
    }
}

#pragma mark - 懒加载
- (iCarousel *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, BANNER_HEIGHT)];
        _scrollView.clipsToBounds = YES;
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.type = iCarouselTypeLinear;
        [_scrollView addSubview:self.pageControl];
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

//- (UIButton *)timeLineButton {
//    if (_timeLineButton == nil) {
//        _timeLineButton = [[UIButton alloc] init];
//        [_timeLineButton setImage:[[UIImage imageNamed:@"home_attention"] imageByTintColor:[UIColor ddp_mainColor]] forState:UIControlStateNormal];
//        _timeLineButton.titleLabel.font = [UIFont ddp_normalSizeFont];
//        [_timeLineButton setTitle:@"时间线" forState:UIControlStateNormal];
//        [_timeLineButton setBackgroundImage:[UIImage imageNamed:@"home_bangumi_group_bg"] forState:UIControlStateNormal];
//        [_timeLineButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        _timeLineButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//        [_timeLineButton addTarget:self action:@selector(touchTimeLineButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_timeLineButton];
//    }
//    return _timeLineButton;
//}
//
//- (UIButton *)searchButton {
//    if (_searchButton == nil) {
//        _searchButton = [[UIButton alloc] init];
//        [_searchButton setImage:[[UIImage imageNamed:@"home_search"] imageByTintColor:[UIColor ddp_mainColor]] forState:UIControlStateNormal];
//        _searchButton.titleLabel.font = [UIFont ddp_normalSizeFont];
//        [_searchButton setTitle:@"搜索资源" forState:UIControlStateNormal];
//        [_searchButton setBackgroundImage:[UIImage imageNamed:@"home_bangumi_group_bg"] forState:UIControlStateNormal];
//        [_searchButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//        [_searchButton addTarget:self action:@selector(touchSearchButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_searchButton];
//    }
//    return _searchButton;
//}

- (NSTimer *)timer {
    if (_timer == nil) {
        @weakify(self)
        _timer = [NSTimer timerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self.scrollView scrollToItemAtIndex:self.scrollView.currentItemIndex + 1 duration:0.8];
        } repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
