//
//  JHBaseDanmaku+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseDanmaku+Tools.h"

static NSString *const filterKey = @"filter";

@implementation JHBaseDanmaku (Tools)

- (void)setFilter:(BOOL)filter {
    objc_setAssociatedObject(self, &filterKey, @(filter), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)filter {
    return [objc_getAssociatedObject(self, &filterKey) boolValue];
}

@end
