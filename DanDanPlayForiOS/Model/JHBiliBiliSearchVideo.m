//
//  JHBiliBiliSearchVideo.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBiliBiliSearchVideo.h"

@implementation JHBiliBiliSearchVideo

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"aid",
             @"name" : @"title",
             @"desc" : @"description",
             @"typeName" : @"typename",
             @"publicTime" : @"pubdate"
             };
}

@end
