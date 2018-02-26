//
//  DDPPofileResponse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPofileResponse.h"

@implementation DDPPofileResponse

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"updatePasswordSuccess" : @"UpdatePasswordSuccess",
             @"updateScreenNameSuccess" : @"UpdateScreenNameSuccess"};
}

@end
