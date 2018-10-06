//
//  DDPSearchAnimeDetails.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPSearchAnimeDetails.h"

@implementation DDPSearchAnimeDetails

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"animeId",
             @"name" : @"animeTitle"
             };
}

@end
