//
//  DDPSetting.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSetting.h"

@implementation DDPSettingItem
- (instancetype)initWithReuseClass:(Class)reuseClass {
    if (self = [super init]) {
        _reuseClass = reuseClass;
    }
    return self;
}

@end

@implementation DDPSetting


- (NSMutableArray<DDPSettingItem *> *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end
