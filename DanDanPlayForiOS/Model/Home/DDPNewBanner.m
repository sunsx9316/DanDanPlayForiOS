//
//  DDPNewBanner.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewBanner.h"

@implementation DDPNewBanner

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name" : @"title",
             @"desc" : @"description"
             };
}

@end
