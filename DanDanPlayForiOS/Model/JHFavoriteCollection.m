//
//  JHFavoriteCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFavoriteCollection.h"

@implementation JHFavoriteCollection

+ (Class)entityClass {
    return [JHFavorite class];
}

+ (NSString *)collectionKey {
    return @"Favorites";
}

@end
