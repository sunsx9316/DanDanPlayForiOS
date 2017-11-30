//
//  JHHomeFeatured.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHHomeFeatured.h"

@implementation JHHomeFeatured
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name" : @"Title",
             @"imageURL" : @"ImageUrl",
             @"category" : @"Category",
             @"desc" : @"Introduction",
             @"link" : @"Url"};
}

@end
