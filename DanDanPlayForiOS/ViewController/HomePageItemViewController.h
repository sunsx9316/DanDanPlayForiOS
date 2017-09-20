//
//  HomePageItemViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseTableView.h"

@interface HomePageItemViewController : BaseViewController
@property (strong, nonatomic) NSArray <JHBangumi *>*bangumis;
@property (copy, nonatomic) void(^handleBannerCallBack)(void);
@property (copy, nonatomic) void(^endRefreshCallBack)(void);
- (void)endRefresh;
@end
