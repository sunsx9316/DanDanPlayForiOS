//
//  DDPFavorite.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFavorite.h"

@implementation DDPFavorite

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"AnimeId",
             @"name" : @"AnimeTitle",
             @"attentionTime" : @"LastUpdate",
             @"imageUrl" : @"ImageUrl",
             @"episodeTotal" : @"EpisodeTotal",
             @"episodeWatched" : @"EpisodeWatched",
             @"isOnAir" : @"IsOnAir"};
}

@end
