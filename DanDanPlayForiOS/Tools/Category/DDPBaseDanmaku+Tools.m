//
//  DDPBaseDanmaku+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseDanmaku+Tools.h"

static NSString *const filterKey = @"filter";
static NSString *const sendByUserIdKey = @"send_by_user_id";

@implementation JHBaseDanmaku (Tools)

- (void)setFilter:(BOOL)filter {
    objc_setAssociatedObject(self, &filterKey, @(filter), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)filter {
    return [objc_getAssociatedObject(self, &filterKey) boolValue];
}

- (void)setSendByUserId:(NSUInteger)sendByUserId {
    objc_setAssociatedObject(self, &sendByUserIdKey, @(sendByUserId), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)sendByUserId {
    return [objc_getAssociatedObject(self, &sendByUserIdKey) integerValue];
}

@end
