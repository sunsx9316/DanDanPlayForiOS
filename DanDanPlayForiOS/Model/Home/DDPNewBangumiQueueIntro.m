//
//  DDPNewBangumiQueueIntro.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewBangumiQueueIntro.h"

@implementation DDPNewBangumiQueueIntro

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"animeId",
             @"name" : @"animeTitle",
             @"desc" : @"description"
             };
}

@end
