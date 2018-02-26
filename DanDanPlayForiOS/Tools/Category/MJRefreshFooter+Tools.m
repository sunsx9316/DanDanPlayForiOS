//
//  MJRefreshFooter+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MJRefreshFooter+Tools.h"

@implementation MJRefreshFooter (Tools)
+ (instancetype)ddp_footRefreshingCompletionHandler:(MJRefreshComponentRefreshingBlock)completionHandler {
    MJRefreshAutoNormalFooter *foot = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:completionHandler];
    foot.automaticallyChangeAlpha = YES;
    foot.stateLabel.font = [UIFont ddp_normalSizeFont];
    [foot setTitle:@"再拉，再拉就刷新给你看" forState:MJRefreshStateIdle];
    [foot setTitle:@"够了啦，松开人家嘛" forState:MJRefreshStatePulling];
    [foot setTitle:@"刷呀刷，好累啊，喵(＾▽＾)" forState:MJRefreshStateRefreshing];
    return foot;
}
@end
