//
//  JHBangumiEpisode.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBangumiEpisode.h"

@implementation JHBangumiEpisode

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"EpisodeId",
             @"name" : @"EpisodeTitle",
             @"airDate" : @"AirDate"
             };
}

@end
