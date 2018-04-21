//
//  DDPRefreshNormalHeader.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/4/21.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPRefreshNormalHeader.h"

@implementation DDPRefreshNormalHeader

- (instancetype)init {
    if (self = [super init]) {
        self.lastUpdatedTimeLabel.hidden = YES;
        self.automaticallyChangeAlpha = YES;
        self.stateLabel.font = [UIFont ddp_normalSizeFont];
    }
    return self;
}

- (void)setState:(MJRefreshState)state {
    if (state == MJRefreshStateRefreshing) {
        self.labelLeftInset = 20;
        [self setTitle:[[DDPCacheManager shareCacheManager].refreshTexts randomObject] forState:MJRefreshStateRefreshing];
    }
    else {
        self.labelLeftInset = 0;
    }
    
    [super setState:state];
}

@end
