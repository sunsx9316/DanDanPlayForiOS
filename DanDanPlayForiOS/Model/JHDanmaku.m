//
//  DanMuModel.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "JHDanmaku.h"

@implementation JHDanmaku
{
    NSNumber *_timerValue;
}

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

- (BOOL)isEqual:(JHDanmaku *)object {
    if ([object isMemberOfClass:[self class]] == NO) return NO;
    
    if ([object.message isEqual:self.message] && object.color == self.color) {
        if ([object.timeValue isEqual:self.timeValue]) return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return self.message.hash | self.color | [self timeValue].hash;
}

#pragma mark - 懒加载
- (NSNumber *)timeValue {
    if (_timerValue == nil) {
        _timerValue = @(self.time);
    }
    return _timerValue;
}

@end
