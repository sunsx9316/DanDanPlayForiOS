//
//  WMStickyPageViewController.h
//  StickyExample
//
//  Created by Tpphha on 2017/7/22.
//  Copyright © 2017年 Tpphha. All rights reserved.
//

#import "DDPDefaultPageViewController.h"
#import "WMMagicScrollView.h"

NS_ASSUME_NONNULL_BEGIN
@class WMStickyPageController;

@protocol WMStickyPageControllerDelegate;

/**
 The self.view is custom UIScrollView
 */
@interface WMStickyPageController : DDPDefaultPageViewController<WMMagicScrollViewDelegate>

@property(nonatomic, strong) WMMagicScrollView *contentView;

/**
 It's determine the sticky locatio.
 */
@property (nonatomic, assign)  CGFloat  minimumHeaderViewHeight;

/**
 The custom headerView's height, default 0 means no effective.
 */
@property (nonatomic, assign) CGFloat maximumHeaderViewHeight;

/**
 The menuView's height, default 44
 */
@property (nonatomic, assign) CGFloat menuViewHeight;

@end

@protocol WMStickyPageControllerDelegate <WMPageControllerDelegate>

@optional
- (BOOL)pageController:(WMStickyPageController *)pageController shouldScrollWithSubview:(UIScrollView *)subview;

@end
NS_ASSUME_NONNULL_END
