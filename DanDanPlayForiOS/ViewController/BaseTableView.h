//
//  BaseTableView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIScrollView+EmptyDataSet.h>

@interface BaseTableView : UITableView
@property (assign, nonatomic, getter=isShowEmptyView) BOOL showEmptyView;
@end
