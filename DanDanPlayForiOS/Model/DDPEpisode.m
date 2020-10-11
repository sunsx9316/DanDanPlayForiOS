//
//  DDPEpisode.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPEpisode.h"
#import "NSDate+Tools.h"

@implementation DDPEpisode

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @[@"Id", @"episodeId", @"EpisodeId"],
             @"name" : @[@"Title", @"episodeTitle", @"EpisodeTitle"],
             @"lastWatchDate" : @[@"Time", @"lastWatched"],
             @"isOnAir" : @[@"IsOnAir", @"isOnAir"]};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *time = dic[@"lastWatched"];
    if ([time isKindOfClass:[NSString class]]) {
        NSDate *date = [NSDate dateWithDefaultFormatString:time];
        self.lastWatchDate = date;        
    }
    return NO;
}

- (NSString *)lastWatchDateString {
    return [NSDate historyTimeStyleWithDate:self.lastWatchDate];
}

@end
