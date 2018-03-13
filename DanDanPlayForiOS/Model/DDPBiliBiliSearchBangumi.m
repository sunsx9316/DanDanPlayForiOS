//
//  DDPBiliBiliSearchBangumi.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliSearchBangumi.h"

@implementation DDPBiliBiliSearchBangumi

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"bangumi_id",
             @"name" : @"title",
             @"desc" : @"evaluate",
             @"danmakuCount" : @"danmaku_count",
             @"isFinish" : @"is_finish",
             @"totalCount" : @"total_count",
             @"publicTime" : @"pubdate"
             };
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSString *cover = dic[@"cover"];
    if ([cover hasPrefix:@"http"] == NO) {
        NSMutableDictionary *mDic = dic.mutableCopy;
        mDic[@"cover"] = [@"https:" stringByAppendingString:cover];
        return mDic;
    }
    return dic;
}

@end
