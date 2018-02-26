//
//  DDPRegisterResponse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPRegisterResponse.h"

@implementation DDPRegisterResponse
@synthesize errorMessage = _errorMessage;
@synthesize success = _success;


+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"errorMessage" : @"ErrorMessage",
             @"success" : @"Success",
             @"identity" : @"UserId",
             @"token" : @"Token"
             };
}

@end
