//
//  DDPHomeBanner.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomeBanner.h"

@implementation DDPHomeBanner

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"desc" : @"Description",
             @"imageURL" : @"ImageUrl",
             @"name" : @"Title",
             @"link" : @"Url"};
}

@end
