//
//  DDPUser.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPUser.h"

@implementation DDPUser

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name" : @"ScreenName",
             @"token" : @"Token",
             @"identity" : @"UserId",
             @"icoImgURL" : @"ProfileImage",
             @"registerRequired" : @"RegisterRequired",
             @"needLogin" : @"NeedLogin",
             @"userType" : @"UserType"
             };
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *aDic = [dic mutableCopy];
    aDic[@"UserType"] = @(ddp_userTypeStringToEnum(aDic[@"UserType"]));
    return aDic;
}

@end
