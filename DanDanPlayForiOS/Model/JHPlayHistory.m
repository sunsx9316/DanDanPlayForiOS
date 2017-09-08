//
//  JHPlayHistory.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHPlayHistory.h"

@implementation JHPlayHistory

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"AnimeId",
             @"name" : @"AnimeTitle",
             @"collection" : @"Episodes",
             @"imageUrl" : @"ImageUrl",
             @"isFavorite" : @"IsFavorite",
             @"searchKeyword" : @"SearchKeyword"};
}

+ (Class)entityClass {
    return [JHEpisode class];
}

@end
