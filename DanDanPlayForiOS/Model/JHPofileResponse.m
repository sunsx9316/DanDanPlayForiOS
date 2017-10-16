//
//  JHPofileResponse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHPofileResponse.h"

@implementation JHPofileResponse

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"updatePasswordSuccess" : @"UpdatePasswordSuccess",
             @"updateScreenNameSuccess" : @"UpdateScreenNameSuccess"};
}

@end
