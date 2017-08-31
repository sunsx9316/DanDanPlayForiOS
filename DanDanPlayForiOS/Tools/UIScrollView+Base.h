//
//  UIScrollView+Base.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshFooter+Tools.h"
#import "MJRefreshHeader+Tools.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface UIScrollView (Base)
@property (assign, nonatomic, getter=isShowEmptyView) BOOL showEmptyView;
@property (assign, nonatomic) CGFloat verticalOffsetForEmptyDataSet;
@property (assign, nonatomic) BOOL allowScroll;
- (void)endRefreshing;
@end
