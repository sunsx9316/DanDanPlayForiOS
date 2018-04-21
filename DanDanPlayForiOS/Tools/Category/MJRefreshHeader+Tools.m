//
//  MJRefreshHeader+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MJRefreshHeader+Tools.h"
#import "DDPRefreshNormalHeader.h"

@implementation MJRefreshHeader (Tools)
+ (instancetype)ddp_headerRefreshingCompletionHandler:(MJRefreshComponentRefreshingBlock)completionHandler {
    MJRefreshNormalHeader *header = [DDPRefreshNormalHeader headerWithRefreshingBlock:completionHandler];
    
    [header setTitle:@"" forState:MJRefreshStateIdle];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    return header;
}
@end
