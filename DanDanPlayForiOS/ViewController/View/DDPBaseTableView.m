//
//  DDPBaseTableView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTableView.h"

@interface DDPBaseTableView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation DDPBaseTableView

- (void)endRefreshing {
    if (self.mj_header.isRefreshing) {
        [self.mj_header endRefreshing];
    }
    
    if (self.mj_footer.isRefreshing) {
        [self.mj_footer endRefreshing];
    }
    
    self.showEmptyView = YES;
    [self reloadEmptyDataSet];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self commitInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commitInit];
}

- (void)commitInit {
    self.emptyDataSetSource = self;
    self.emptyDataSetDelegate = self;
    self.backgroundColor = [UIColor ddp_backgroundColor];
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
}

@end
