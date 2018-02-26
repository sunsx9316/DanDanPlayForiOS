//
//  DDPPlayHistory.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayHistory.h"

@implementation DDPPlayHistory

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"identity" : @"AnimeId",
             @"name" : @"AnimeTitle",
             @"collection" : @"Episodes",
             @"imageUrl" : @"ImageUrl",
             @"isFavorite" : @"IsFavorite",
             @"searchKeyword" : @"SearchKeyword"};
}

+ (Class)entityClass {
    return [DDPEpisode class];
}

- (NSString *)playHistoryStatusString {
    if (self.collection.count) {
        __block BOOL seeOver = YES;
        [self.collection enumerateObjectsUsingBlock:^(DDPEpisode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //没看过
            if (obj.time.length == 0) {
                seeOver = NO;
                *stop = YES;
            }
        }];
        
        if (seeOver) {
            return @"已看完";
        }
    }
    
    if (_isOnAir) {
        return @"连载中";
    }
    
    return @"已完结";
}

@end
