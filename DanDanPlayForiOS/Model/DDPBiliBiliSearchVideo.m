//
//  DDPBiliBiliSearchVideo.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliSearchVideo.h"

@implementation DDPBiliBiliSearchVideo

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"aid",
             @"name" : @"title",
             @"desc" : @"description",
             @"typeName" : @"typename",
             @"publicTime" : @"pubdate"
             };
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *mDic = dic.mutableCopy;
    
    NSString *cover = mDic[@"pic"];
    if ([cover hasPrefix:@"http"] == NO) {
        mDic[@"pic"] = [@"https:" stringByAppendingString:cover];
    }
    
    NSString *duration = dic[@"duration"];
    if (duration.length > 0) {
        NSArray <NSString *>*durations = [duration componentsSeparatedByString:@":"];
        NSMutableString *mStr = [[NSMutableString alloc] init];
        [durations enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //转化为03:00的形式
            if (obj.length == 1) {
                [mStr appendFormat:@"0%@:", obj];
            }
            else {
                [mStr appendFormat:@"%@:", obj];
            }
        }];
        
        if (mStr.length > 0) {
            [mStr deleteCharactersInRange:NSMakeRange(mStr.length - 1, 1)];
            mDic[@"duration"] = mStr;
        }
    }
    
    return mDic;
}
@end
