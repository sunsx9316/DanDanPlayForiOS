//
//  DanMuModel.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "JHDanmaku.h"

@interface JHDanmaku ()
@property (copy, nonatomic) NSString *timeStringValue;
@end

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

- (BOOL)isEqual:(JHDanmaku *)object {
    if ([object isMemberOfClass:[self class]] == NO) return NO;
    
    if ([object.message isEqual:self.message] && object.color == self.color) {
        if ([object.timeStringValue isEqual:self.timeStringValue]) return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return self.message.hash | self.color | self.timeStringValue.hash;
}

#pragma mark - 懒加载
- (NSString *)timeStringValue {
    if (_timeStringValue == nil) {
        _timeStringValue = [NSString stringWithFormat:@"%.2f", self.time];
    }
    return _timeStringValue;
}

@end
