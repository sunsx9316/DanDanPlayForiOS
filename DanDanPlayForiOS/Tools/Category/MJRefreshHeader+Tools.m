//
//  MJRefreshHeader+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MJRefreshHeader+Tools.h"

@implementation MJRefreshHeader (Tools)
+ (instancetype)ddp_headerRefreshingCompletionHandler:(MJRefreshComponentRefreshingBlock)completionHandler {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:completionHandler];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.automaticallyChangeAlpha = YES;
    header.stateLabel.font = [UIFont ddp_normalSizeFont];
    [header setTitle:@"再拉，再拉就刷新给你看" forState:MJRefreshStateIdle];
    [header setTitle:@"够了啦，松开人家嘛" forState:MJRefreshStatePulling];
    [header setTitle:@"刷呀刷，好累啊，喵(＾▽＾)" forState:MJRefreshStateRefreshing];
    return header;
}
@end
