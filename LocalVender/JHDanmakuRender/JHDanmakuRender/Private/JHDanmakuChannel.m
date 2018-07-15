//
//  JHDanmakuChannel.m
//  iOSDemo
//
//  Created by Developer2 on 2017/11/14.
//  Copyright © 2017年 jim. All rights reserved.
//

#import "JHDanmakuChannel.h"

@implementation JHDanmakuChannelParameter

@end

@implementation JHDanmakuChannel

- (NSMutableArray<JHDanmakuChannelParameter *> *)danmakuParameters {
    if (_danmakuParameters == nil) {
        _danmakuParameters = [NSMutableArray array];
    }
    return _danmakuParameters;
}

@end
