//
//  JHBiliBiliSearchResult.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBiliBiliSearchResult.h"

@implementation JHBiliBiliSearchResult

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"bangumi" : @"result.bangumi",
             @"video" : @"result.video"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"bangumi" : [JHBiliBiliSearchBangumi class],
             @"video" : [JHBiliBiliSearchVideo class]
             };
}

@end
