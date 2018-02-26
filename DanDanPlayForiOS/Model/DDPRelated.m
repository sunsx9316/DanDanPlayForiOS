//
//  DDPRelated.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPRelated.h"

@implementation DDPRelated

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"provider" : @"Provider",
             @"url" : @"Url",
             @"shift" : @"Shift",};
}

@end
