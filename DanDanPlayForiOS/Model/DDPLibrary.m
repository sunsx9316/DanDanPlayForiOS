//
//  DDPLibrary.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLibrary.h"

@implementation DDPLibrary

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"AnimeId",
             @"episodeId" : @"EpisodeId",
             @"name" : @"Name",
             @"animeTitle" : @"AnimeTitle",
             @"episodeTitle" : @"EpisodeTitle",
             @"md5" : @"Hash",
             @"path" : @"Path",
             @"size" : @"Size",
             @"rate" : @"Rate",
             @"created" : @"Created",
             @"lastPlay" : @"LastPlay",
             @"duration" : @"Duration",
             @"position" : @"Position",
             @"seekable" : @"Seekable",
             @"volume" : @"Volume",
             @"playing" : @"Playing",
             @"playId" : @"Id"
             };
}

@end
