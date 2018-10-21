//
//  DanMuModel.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPDanmaku.h"

@implementation DDPDanmaku
{
    NSNumber *_timerValue;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"time":@"Time",
             @"mode":@"Mode",
             @"color":@"Color",
             @"message": @[@"Message", @"m"],
             @"timestamp" : @"Timestamp",
             @"UId" : @"UId",
             @"identity" : @[@"CId", @"cid"]};
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"filter"];
}

- (BOOL)isEqual:(DDPDanmaku *)object {
    if ([object isMemberOfClass:[self class]] == NO) return NO;
    
    if ([object.message isEqual:self.message] && object.color == self.color) {
        if ([object.timeValue isEqual:self.timeValue]) return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return self.message.hash | self.color | [self timeValue].hash;
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    //"p": "147.32,1,16777215,[BiliBili]d9840c43",
    NSString *p = dic[@"p"];
    
    if ([p isKindOfClass:[NSString class]]) {
        NSMutableDictionary *mDic = [dic mutableCopy];
        NSArray <NSString *>*arr = [p componentsSeparatedByString:@","];
        if (arr.count > 0) {
            mDic[@"Time"] = arr.firstObject;
        }
        
        if (arr.count > 1) {
            mDic[@"Mode"] = arr[1];
        }
        
        if (arr.count > 2) {
            mDic[@"Color"] = arr[2];
        }
        
        if (arr.count > 3) {
            mDic[@"UId"] = arr[3];
        }
        
        return mDic;
    }
    
    return dic;
}

#pragma mark - 懒加载
- (NSNumber *)timeValue {
    if (_timerValue == nil) {
        _timerValue = @(self.time);
    }
    return _timerValue;
}

@end
