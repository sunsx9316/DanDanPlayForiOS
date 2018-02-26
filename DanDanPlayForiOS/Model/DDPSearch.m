//
//  DDPSearch.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSearch.h"

@implementation DDPSearch

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"episodes" : @"Episodes",
             @"name" : @"Title",
             @"type" : @"Type"};
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"episodes" : [DDPEpisode class]};
}

@end
