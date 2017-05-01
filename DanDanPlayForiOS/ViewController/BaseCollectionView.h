//
//  BaseCollectionView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/29.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIScrollView+EmptyDataSet.h>
#import "MJRefreshFooter+Tools.h"
#import "MJRefreshHeader+Tools.h"

@interface BaseCollectionView : UICollectionView
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
