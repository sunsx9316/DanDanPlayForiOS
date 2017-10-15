//
//  JHUser.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHUser.h"

@implementation JHUser

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
    aDic[@"UserType"] = @(jh_userTypeStringToEnum(aDic[@"UserType"]));
    return aDic;
}

@end
