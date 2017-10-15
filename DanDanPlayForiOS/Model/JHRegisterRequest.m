//
//  JHRegisterRequest.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHRegisterRequest.h"

@implementation JHRegisterRequest

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name" : @"ScreenName",
             @"account" : @"UserName",
             @"password" : @"Password",
             @"email" : @"Email",
             @"userId" : @"UserId",
             @"token" : @"Token"};
}

@end
