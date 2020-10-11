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
    return @{@"identity" : @"animeId",
             @"name" : @"animeTitle",
             @"attentionTime" : @"lastFavoriteTime",
             @"imageUrl" : @"imageUrl",
             @"episodeTotal" : @"episodeTotal",
             @"episodeWatched" : @"episodeWatched",
             @"isOnAir" : @"isOnAir"};
}

@end
