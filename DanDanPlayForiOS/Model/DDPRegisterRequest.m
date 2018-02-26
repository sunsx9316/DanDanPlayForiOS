//
//  DDPRegisterRequest.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPRegisterRequest.h"

@implementation DDPRegisterRequest

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name" : @"ScreenName",
             @"account" : @"UserName",
             @"password" : @"Password",
             @"email" : @"Email",
             @"userId" : @"UserId",
             @"token" : @"Token"};
}

@end
