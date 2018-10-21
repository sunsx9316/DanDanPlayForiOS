//
//  DDPHomePageItemViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"
#import "DDPBaseTableView.h"

@interface DDPHomePageItemViewController : DDPBaseViewController
@property (strong, nonatomic) NSArray <DDPHomeBangumi *>*bangumis;
@property (copy, nonatomic) void(^handleBannerCallBack)(void);
@property (copy, nonatomic) void(^endRefreshCallBack)(void);
- (void)endRefresh;
@end
