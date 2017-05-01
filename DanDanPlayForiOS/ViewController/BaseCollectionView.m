//
//  BaseCollectionView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/29.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseCollectionView.h"

@interface BaseCollectionView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation BaseCollectionView

- (void)endRefreshing {
    [self.mj_header endRefreshing];
    self.showEmptyView = YES;
    [self reloadEmptyDataSet];
}


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.emptyDataSetSource = self;
        self.emptyDataSetDelegate = self;
        self.backgroundColor = BACK_GROUND_COLOR;
        //        _verticalOffsetForEmptyDataSet = 50;
    }
    return self;
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
    return _showEmptyView;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self.mj_header beginRefreshing];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return _verticalOffsetForEmptyDataSet;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return _allowScroll;
}

@end
