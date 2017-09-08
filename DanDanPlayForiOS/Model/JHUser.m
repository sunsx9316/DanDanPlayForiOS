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
             @"icoImgURL" : @"ProfileImage"};
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *aDic = [dic mutableCopy];
    if ([aDic[@"UserType"] isEqualToString:@"weibo"]) {
        aDic[@"UserType"] = @(JHUserTypeWeibo);
    }
    else if ([aDic[@"UserType"] isEqualToString:@"qq"]) {
        aDic[@"UserType"] = @(JHUserTypeQQ);
    }
    return aDic;
}

@end
