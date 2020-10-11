//
//  DDPBangumiEpisode.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBangumiEpisode.h"

@implementation DDPBangumiEpisode

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @[@"EpisodeId", @"episodeId"],
             @"name" : @[@"EpisodeTitle", @"episodeTitle"],
             @"airDate" : @[@"AirDate", @"airDate"]
             };
}

@end
