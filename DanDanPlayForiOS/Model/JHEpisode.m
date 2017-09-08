//
//  JHEpisode.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHEpisode.h"

@implementation JHEpisode

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @[@"Id", @"EpisodeId"],
             @"name" : @[@"Title", @"EpisodeTitle"],
             @"time" : @"Time",
             @"isOnAir" : @"IsOnAir"};
}

@end
