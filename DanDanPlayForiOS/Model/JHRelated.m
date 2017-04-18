//
//  JHRelated.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHRelated.h"

@implementation JHRelated

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"provider" : @"Provider",
             @"url" : @"Url",
             @"shift" : @"Shift",};
}

@end
