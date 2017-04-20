//
//  BaseTreeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseTreeView.h"

@interface BaseTreeView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation BaseTreeView

- (void)endRefreshing {
    [self.jh_tableView.mj_header endRefreshing];
    self.showEmptyView = YES;
    [self.jh_tableView reloadEmptyDataSet];
}

- (instancetype)initWithFrame:(CGRect)frame style:(RATreeViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.jh_tableView.emptyDataSetSource = self;
        self.jh_tableView.emptyDataSetDelegate = self;
        self.jh_tableView.tableFooterView = [[UIView alloc] init];
        self.backgroundColor = BACK_GROUND_COLOR;
//        _verticalOffsetForEmptyDataSet = 50;
    }
    return self;
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击重试" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return _showEmptyView;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self.jh_tableView.mj_header beginRefreshing];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return _verticalOffsetForEmptyDataSet;
}

@end

@implementation RATreeView (Tools)

- (UITableView *)jh_tableView {
    return [self valueForKey:@"tableView"];
}

@end
