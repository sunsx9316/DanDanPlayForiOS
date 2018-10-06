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

- (void)setTitleForEmptyView:(NSString *)titleForEmptyView {
    objc_setAssociatedObject(self, @selector(titleForEmptyView), titleForEmptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)titleForEmptyView {
    NSString *title = objc_getAssociatedObject(self, _cmd);
    
    if (title == nil) {
        title = @"暂无数据";
        self.titleForEmptyView = title;
    }
    return title;
}

- (void)setDescriptionForEmptyView:(NSString *)descriptionForEmptyView {
    objc_setAssociatedObject(self, @selector(descriptionForEmptyView), descriptionForEmptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)descriptionForEmptyView {
    NSString *title = objc_getAssociatedObject(self, _cmd);
    
    if (title == nil) {
        title = @"点击刷新";
        self.descriptionForEmptyView = title;
    }
    return title;
}

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
    if (self.titleForEmptyView) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.titleForEmptyView attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        return str;
    }
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.descriptionForEmptyView) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.descriptionForEmptyView attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        return str;
    }
    return nil;
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
