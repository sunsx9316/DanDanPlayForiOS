//
//  DDPCollectionCache.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  收藏缓存

#import "DDPBase.h"

typedef NS_ENUM(NSUInteger, DDPCollectionCacheType) {
    DDPCollectionCacheTypeLocal,
    DDPCollectionCacheTypeComputer,
    DDPCollectionCacheTypeRemoteEquipment,
};

CG_INLINE NSString *DDPCollectionCacheTypeStringValue(DDPCollectionCacheType type) {
    switch (type) {
        case DDPCollectionCacheTypeLocal:
            return @"本地";
        case DDPCollectionCacheTypeComputer:
            return @"我的电脑";
        case DDPCollectionCacheTypeRemoteEquipment:
            return @"局域网设备";
        default:
            return nil;
    }
};

@interface DDPCollectionCache : DDPBase
@property (assign, nonatomic) DDPCollectionCacheType cacheType;
@property (strong, nonatomic) NSString *filePath;
@end
