//
//  JHCollectionCache.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  收藏缓存

#import "JHBase.h"

typedef NS_ENUM(NSUInteger, JHCollectionCacheType) {
    JHCollectionCacheTypeLocal,
    JHCollectionCacheTypeComputer,
    JHCollectionCacheTypeRemoteEquipment,
};

CG_INLINE NSString *JHCollectionCacheTypeStringValue(JHCollectionCacheType type) {
    switch (type) {
        case JHCollectionCacheTypeLocal:
            return @"本地";
        case JHCollectionCacheTypeComputer:
            return @"我的电脑";
        case JHCollectionCacheTypeRemoteEquipment:
            return @"远程设备";
        default:
            return nil;
    }
};

@interface JHCollectionCache : JHBase
@property (assign, nonatomic) JHCollectionCacheType cacheType;
@property (strong, nonatomic) NSString *filePath;
@end
