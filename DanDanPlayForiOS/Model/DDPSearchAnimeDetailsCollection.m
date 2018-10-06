//
//  DDPSearchAnimeDetailsCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPSearchAnimeDetailsCollection.h"

@implementation DDPSearchAnimeDetailsCollection

+ (Class)entityClass {
    return [DDPSearchAnimeDetails class];
}

+ (NSString *)collectionKey {
    return @"animes";
}

@end
