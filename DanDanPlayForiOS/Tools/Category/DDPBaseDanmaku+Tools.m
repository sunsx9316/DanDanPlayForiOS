//
//  DDPBaseDanmaku+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseDanmaku+Tools.h"

@implementation JHBaseDanmaku (Tools)

- (void)setFilter:(BOOL)filter {
    objc_setAssociatedObject(self, @selector(filter), @(filter), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)filter {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSendByUserId:(NSUInteger)sendByUserId {
    objc_setAssociatedObject(self, @selector(sendByUserId), @(sendByUserId), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)sendByUserId {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end
