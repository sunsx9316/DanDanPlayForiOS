//
//  JHBaseTreeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseTreeView.h"

@interface JHBaseTreeView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation JHBaseTreeView

- (void)endRefreshing {
    if (self.jh_tableView.mj_header.isRefreshing) {
        [self.jh_tableView.mj_header endRefreshing];
    }
    
    if (self.jh_tableView.mj_footer.isRefreshing) {
        [self.jh_tableView.mj_footer endRefreshing];
    }
    
    self.jh_tableView.showEmptyView = YES;
    [self.jh_tableView reloadEmptyDataSet];
}

- (instancetype)initWithFrame:(CGRect)frame style:(RATreeViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.jh_tableView.emptyDataSetSource = self;
        self.jh_tableView.emptyDataSetDelegate = self;
        self.jh_tableView.tableFooterView = [[UIView alloc] init];
        self.backgroundColor = BACK_GROUND_COLOR;
        if (@available(iOS 11.0, *)) {
            self.jh_tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

@end

@implementation RATreeView (Tools)

- (UITableView *)jh_tableView {
    return [self valueForKey:@"tableView"];
}

@end
