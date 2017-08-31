//
//  UIScrollView+Base.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIScrollView+Base.h"
#import <UIScrollView+EmptyDataSet.h>

static int *showEmptyViewKey;
static int *verticalOffsetForEmptyDataSetKey;
static int *allowScrollKey;

@implementation UIScrollView (Base)

- (void)setShowEmptyView:(BOOL)showEmptyView {
    objc_setAssociatedObject(self, &showEmptyViewKey, @(showEmptyView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isShowEmptyView {
    NSNumber *value = objc_getAssociatedObject(self, &showEmptyViewKey);
    return value.boolValue;
}

- (void)setVerticalOffsetForEmptyDataSet:(CGFloat)verticalOffsetForEmptyDataSet {
    objc_setAssociatedObject(self, &verticalOffsetForEmptyDataSetKey, @(verticalOffsetForEmptyDataSet), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)verticalOffsetForEmptyDataSet {
    NSNumber *value = objc_getAssociatedObject(self, &verticalOffsetForEmptyDataSetKey);
    return value.floatValue;
}

- (void)setAllowScroll:(BOOL)allowScroll {
    objc_setAssociatedObject(self, &allowScrollKey, @(allowScroll), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)allowScroll {
    NSNumber *value = objc_getAssociatedObject(self, &allowScrollKey);
    return value.boolValue;
}

- (void)endRefreshing {
    
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击重试" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.showEmptyView;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self.mj_header beginRefreshing];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return self.verticalOffsetForEmptyDataSet;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return self.allowScroll;
}

@end
