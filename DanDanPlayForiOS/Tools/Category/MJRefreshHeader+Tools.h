//
//  MJRefreshHeader+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@interface MJRefreshHeader (Tools)

/**
 *  默认的刷新方式
 *
 *  @param completionHandler 刷新回调
 *
 *  @return self
 */
+ (instancetype)ddp_headerRefreshingCompletionHandler:(MJRefreshComponentAction)completionHandler;
@end
