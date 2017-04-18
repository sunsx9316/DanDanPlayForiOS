//
//  JHBiliBiliSearch.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBiliBiliSearch.h"

@implementation JHBiliBiliSearch

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identity" : @"season_id",
             @"desc" : @"description",
             @"bangumi" : @"is_bangumi"};
}

@end
