//
//  DDPFavoriteCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFavoriteCollection.h"

@implementation DDPFavoriteCollection

+ (Class)entityClass {
    return [DDPFavorite class];
}

+ (NSString *)collectionKey {
    return @"favorites";
}

@end
