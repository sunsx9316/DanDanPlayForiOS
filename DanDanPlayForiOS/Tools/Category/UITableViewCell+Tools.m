//
//  UITableViewCell+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UITableViewCell+Tools.h"

static int *fromCacheKey;

@implementation UITableViewCell (Tools)

- (void)setFromCache:(BOOL)fromCache {
    objc_setAssociatedObject(self, &fromCacheKey, @(fromCache), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isFromCache {
    NSNumber *number = objc_getAssociatedObject(self, &fromCacheKey);
    return number.boolValue;
}

@end
