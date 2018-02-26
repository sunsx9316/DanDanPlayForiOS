//
//  DDPBaseTreeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTreeView.h"

@interface DDPBaseTreeView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation DDPBaseTreeView

- (void)endRefreshing {
    if (self.ddp_tableView.mj_header.isRefreshing) {
        [self.ddp_tableView.mj_header endRefreshing];
    }
    
    if (self.ddp_tableView.mj_footer.isRefreshing) {
        [self.ddp_tableView.mj_footer endRefreshing];
    }
    
    self.ddp_tableView.showEmptyView = YES;
    [self.ddp_tableView reloadEmptyDataSet];
}

- (instancetype)initWithFrame:(CGRect)frame style:(RATreeViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.ddp_tableView.emptyDataSetSource = self;
        self.ddp_tableView.emptyDataSetDelegate = self;
        self.ddp_tableView.tableFooterView = [[UIView alloc] init];
        self.backgroundColor = [UIColor ddp_backgroundColor];
        if (@available(iOS 11.0, *)) {
            self.ddp_tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

@end

@implementation RATreeView (Tools)

- (UITableView *)ddp_tableView {
    return [self valueForKey:@"tableView"];
}

@end
