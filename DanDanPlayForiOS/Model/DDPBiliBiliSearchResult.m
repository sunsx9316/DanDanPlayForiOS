//
//  DDPBiliBiliSearchResult.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliSearchResult.h"

@implementation DDPBiliBiliSearchResult

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"bangumi" : @"result.bangumi",
             @"video" : @"result.video"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"bangumi" : [DDPBiliBiliSearchBangumi class],
             @"video" : [DDPBiliBiliSearchVideo class]
             };
}

@end
