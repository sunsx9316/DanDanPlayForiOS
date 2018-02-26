//
//  DDPBangumiQueueIntro.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBangumiQueueIntro.h"

@implementation DDPBangumiQueueIntro

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    NSMutableDictionary *dic = [[super modelCustomPropertyMapper] mutableCopy];
    [dic addEntriesFromDictionary:@{@"identity" : @"AnimeId",
                                    @"name" : @"AnimeTitle",
                                    @"desc" : @"Description",
                                    @"episodeTitle" : @"EpisodeTitle",
                                    @"airDate" : @"AirDate",
                                    @"imageUrl" : @"ImageUrl",
                                    @"isOnAir" : @"IsOnAir",
                                    @"searchKeyword" : @"SearchKeyword",
                                    @"lastWatched" : @"LastWatched"
                                    }];
    return dic;
}

+ (Class)entityClass {
    return [DDPBangumiEpisode class];
}

+ (NSString *)collectionKey {
    return @"Episodes";
}

@end
