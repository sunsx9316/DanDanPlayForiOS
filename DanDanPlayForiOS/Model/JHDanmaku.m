//
//  DanMuModel.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "JHDanmaku.h"

@implementation JHDanmaku

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"time":@"Time",
             @"mode":@"Mode",
             @"color":@"Color",
             @"message":@"Message",
             @"timestamp" : @"Timestamp",
             @"pool" : @"Pool",
             @"userId" : @"UId",
             @"identity" : @"CId",
             @"token" : @"Token"};
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"filter"];
}

@end
