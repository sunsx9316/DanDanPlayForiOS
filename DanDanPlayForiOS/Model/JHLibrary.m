//
//  JHLibrary.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHLibrary.h"

@implementation JHLibrary

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"AnimeId",
             @"EpisodeId" : @"episodeId",
             @"name" : @"Name",
             @"animeTitle" : @"AnimeTitle",
             @"episodeTitle" : @"EpisodeTitle",
             @"md5" : @"Hash",
             @"path" : @"Path",
             @"size" : @"Size",
             @"rate" : @"Rate",
             @"created" : @"Created",
             @"lastPlay" : @"LastPlay",
             @"duration" : @"Duration"};
}

@end
