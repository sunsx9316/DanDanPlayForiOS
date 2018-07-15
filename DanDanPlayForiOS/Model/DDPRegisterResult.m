//
//  DDPRegisterResult.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/6/14.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPRegisterResult.h"

@implementation DDPRegisterResult

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"UserId",
             @"token" : @"Token"
             };
}

@end
