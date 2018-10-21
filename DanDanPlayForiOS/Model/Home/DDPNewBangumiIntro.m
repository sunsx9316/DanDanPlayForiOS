//
//  DDPNewBangumiIntro.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewBangumiIntro.h"

@implementation DDPNewBangumiIntro

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"animeId",
             @"name" : @"animeTitle"
             };
}

@end
