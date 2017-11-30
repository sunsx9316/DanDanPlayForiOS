//
//  JHHomeBanner.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHHomeBanner.h"

@implementation JHHomeBanner

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"desc" : @"Description",
             @"imageURL" : @"ImageUrl",
             @"name" : @"Title",
             @"link" : @"Url"};
}

@end
