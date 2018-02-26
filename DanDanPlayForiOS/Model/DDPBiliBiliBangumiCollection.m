//
//  DDPBiliBiliBangumiCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliBangumiCollection.h"

@implementation DDPBiliBiliBangumiCollection

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"desc" : @"brief",
             @"collection" : @"episodes",
             @"name" : @"title",
             @"imgURL" : @"cover"};
}

@end
