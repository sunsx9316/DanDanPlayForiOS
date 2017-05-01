//
//  BaseTreeView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <RATreeView/RATreeView.h>
#import <UIScrollView+EmptyDataSet.h>
#import "MJRefreshFooter+Tools.h"
#import "MJRefreshHeader+Tools.h"

@interface BaseTreeView : RATreeView
@property (assign, nonatomic, getter=isShowEmptyView) BOOL showEmptyView;
@property (assign, nonatomic) CGFloat verticalOffsetForEmptyDataSet;
@property (assign, nonatomic) BOOL allowScroll;
/**
 *  [self.mj_header endRefreshing];
 self.showEmptyView = YES;
 [self reloadEmptyDataSet];
 */
- (void)endRefreshing;
@end


@interface RATreeView (Tools)
@property (strong, nonatomic, readonly) UITableView *jh_tableView;
@end
