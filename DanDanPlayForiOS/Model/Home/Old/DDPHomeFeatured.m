//
//  DDPHomeFeatured.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomeFeatured.h"

@implementation DDPHomeFeatured
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name" : @"Title",
             @"imageURL" : @"ImageUrl",
             @"category" : @"Category",
             @"desc" : @"Introduction",
             @"link" : @"Url"};
}

@end
