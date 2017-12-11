//
//  HomePageItemViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseViewController.h"
#import "JHBaseTableView.h"

@interface HomePageItemViewController : JHBaseViewController
@property (strong, nonatomic) NSArray <JHHomeBangumi *>*bangumis;
@property (copy, nonatomic) void(^handleBannerCallBack)(void);
@property (copy, nonatomic) void(^endRefreshCallBack)(void);
- (void)endRefresh;
@end
