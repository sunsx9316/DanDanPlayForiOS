//
//  DDPMatch.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMatch.h"

@implementation DDPMatch

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identity" : @"EpisodeId",
             @"name" : @"EpisodeTitle",
             @"animeTitle" : @"AnimeTitle",
             @"type" : @"Type"};
}

@end
