//
//  DDPCacheManager+multiply.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCacheManager+multiply.h"
#import "DDPCacheManager+Private.h"
#import "DDPCacheManager+DB.h"

#import "DDPFilter+DB.h"
#import "DDPVideoCache+DB.h"
#import "DDPSMBFileHashCache+DB.h"
#import "DDPCollectionCache+DB.h"
#import "DDPSMBInfo+WCDB.h"
#import "DDPLinkInfo+DB.h"
#import "DDPUser+WCTTableCoding.h"

NS_INLINE NSString *ddp_cacheKey(TOSMBSessionFile *file) {
    return [NSString stringWithFormat:@"%@_%llu", file.name, file.fileSize];
};

@interface DDPCacheManager ()<TOSMBSessionTaskDelegate>
@property (strong, nonatomic) NSMutableOrderedSet <DDPFilter *>*mDanmakuFilters;
@property (strong, nonatomic) NSMutableOrderedSet <DDPLinkInfo *>*mLinkInfoHistorys;
@end

@implementation DDPCacheManager (multiply)

- (void)addObserver:(id<DDPCacheManagerDelagate>)observer {
    if (!observer) return;
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<DDPCacheManagerDelagate>)observer {
    if (!observer) return;
    [self.observers removeObject:observer];
}

#pragma mark -
- (NSArray<DDPFilter *> *)danmakuFilters {
    return self.mDanmakuFilters.array;
}

- (UInt64)filterHash {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    
    if (value == nil) {
        
        __block NSInteger flag = 0;
        
        NSArray <DDPFilter *>*arr = [self.danmakuFilters sortedArrayUsingComparator:^NSComparisonResult(DDPFilter * _Nonnull obj1, DDPFilter * _Nonnull obj2) {
            return [obj1.content compare:obj2.content];
        }];
        
        [arr enumerateObjectsUsingBlock:^(DDPFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            flag = flag ^ obj.content.hash;
        }];
        
        value = @(flag);
        objc_setAssociatedObject(self, @selector(filterHash), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return value.unsignedIntegerValue;
}

- (void)clearFilterHash {
    objc_setAssociatedObject(self, @selector(filterHash), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableOrderedSet<DDPFilter *> *)mDanmakuFilters {
    NSMutableOrderedSet<DDPFilter *> *_mDanmakuFilters = objc_getAssociatedObject(self, _cmd);
    if (_mDanmakuFilters == nil) {

        WCTDatabase *db = [DDPCacheManager shareDB];
        NSArray *datas = [db getAllObjectsOfClass:DDPFilter.class fromTable:DDPFilter.className];
        if (datas) {
            _mDanmakuFilters = [NSMutableOrderedSet orderedSetWithArray:datas];
        }
        else {
            _mDanmakuFilters = [NSMutableOrderedSet orderedSet];
        }

        objc_setAssociatedObject(self, _cmd, _mDanmakuFilters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return _mDanmakuFilters;
}

- (void)addFilter:(DDPFilter *)model {
    if (model) {
        [self addFilters:@[model]];
    }
}

- (void)removeFilter:(DDPFilter *)model {
    if (model) {
        [self removeFilters:@[model]];
    }
}

- (void)addFilters:(NSArray<DDPFilter *> *)models {
    if (models.count == 0) return;
    
    [self.mDanmakuFilters addObjectsFromArray:models];
    [self clearFilterHash];
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObjects:models into:DDPFilter.className];
}

- (void)removeFilters:(NSArray<DDPFilter *> *)models {
    if (models.count == 0) return;
    
    [self.mDanmakuFilters removeObjectsInArray:models];
    [self clearFilterHash];
    WCTDatabase *db = [DDPCacheManager shareDB];
    NSString *tableName = DDPFilter.className;
    [db runTransaction:^BOOL{
        for (DDPFilter *obj in models) {
            [db deleteObjectsFromTable:tableName where:DDPFilter.name == obj.name];
        }
        
        return YES;
    }];
}

#pragma mark -
- (NSArray<DDPLinkInfo *> *)linkInfoHistorys {
    return self.mLinkInfoHistorys.array;
}

- (NSMutableOrderedSet<DDPFilter *> *)mLinkInfoHistorys {
    NSMutableOrderedSet<DDPFilter *> *_mLinkInfoHistorys = objc_getAssociatedObject(self, _cmd);
    if (_mLinkInfoHistorys == nil) {
        WCTDatabase *db = [DDPCacheManager shareDB];
        NSArray *datas = [db getAllObjectsOfClass:DDPLinkInfo.class fromTable:DDPLinkInfo.className];
        if (datas) {
            _mLinkInfoHistorys = [NSMutableOrderedSet orderedSetWithArray:datas];
        }
        else {
            _mLinkInfoHistorys = [NSMutableOrderedSet orderedSet];
        }
        objc_setAssociatedObject(self, _cmd, _mLinkInfoHistorys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return _mLinkInfoHistorys;
}

- (DDPLinkInfo *)lastLinkInfo {
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getOneObjectOfClass:DDPLinkInfo.class fromTable:DDPLinkInfo.className orderBy:DDPLinkInfo.saveTime.order(WCTOrderedDescending)];
}

- (void)addLinkInfo:(DDPLinkInfo *)linkInfo {
    if (linkInfo == nil) return;
    
    [self.mLinkInfoHistorys addObject:linkInfo];
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:linkInfo into:DDPLinkInfo.className];
}

- (void)removeLinkInfo:(DDPLinkInfo *)linkInfo {
    if (linkInfo == nil) return;
    
    [self.mLinkInfoHistorys removeObject:linkInfo];
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db deleteObjectsFromTable:linkInfo.className where:DDPLinkInfo.selectedIpAdress == linkInfo.selectedIpAdress];
}

#pragma mark -

- (void)saveEpisodeId:(NSUInteger)episodeId episodeName:(NSString *)episodeName videoModel:(DDPVideoModel *)model {
    if (model.fileHash.length == 0 || episodeName.length == 0 || episodeId == 0) return;
    WCTDatabase *db = [DDPCacheManager shareDB];
    DDPVideoCache *cache = [self relevanceCacheWithVideoModel:model];
    if (cache == nil) {
        cache = [[DDPVideoCache alloc] init];
        cache.fileHash = model.fileHash;
    }
    
    cache.identity = episodeId;
    cache.name = episodeName;
    
    [db insertOrReplaceObject:cache into:DDPVideoCache.className];
}

- (void)saveLastPlayTime:(NSInteger)time videoModel:(DDPVideoModel *)model {
    if (model.fileHash.length == 0) return;
    WCTDatabase *db = [DDPCacheManager shareDB];
    DDPVideoCache *cache = [self relevanceCacheWithVideoModel:model];
    if (cache == nil) {
        cache = [[DDPVideoCache alloc] init];
        cache.fileHash = model.fileHash;
    }
    
    cache.lastPlayTime = time;
    
    [db insertOrReplaceObject:cache into:DDPVideoCache.className];
}

- (DDPVideoCache *)relevanceCacheWithVideoModel:(DDPVideoModel *)model {
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getOneObjectOfClass:DDPVideoCache.class fromTable:DDPVideoCache.className where:DDPVideoCache.fileHash == model.fileHash];
}

#pragma mark -

- (NSArray<DDPSMBInfo *> *)SMBLinkInfos {
#if !DDPAPPTYPEISMAC
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getAllObjectsOfClass:DDPSMBInfo.class fromTable:DDPSMBInfo.className];
#else
    return nil;
#endif
}

- (void)saveSMBInfo:(DDPSMBInfo *)info {
    if (info == nil) return;
    #if !DDPAPPTYPEISMAC
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:info into:DDPSMBInfo.className];
    #endif
}

- (void)removeSMBInfo:(DDPSMBInfo *)info {
    if (info == nil) return;
    #if !DDPAPPTYPEISMAC
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db deleteObjectsFromTable:info.className where:DDPSMBInfo.hostName == info.hostName && DDPSMBInfo.userName == info.userName && DDPSMBInfo.password == info.password];
    #endif
}

#pragma mark -
- (void)saveSMBFileHashWithHash:(NSString *)hash file:(TOSMBSessionFile *)file {
    if (file == nil) return;
    #if !DDPAPPTYPEISMAC
    DDPSMBFileHashCache *cache = [[DDPSMBFileHashCache alloc] init];
    cache.md5 = hash;
    cache.date = [NSDate date];
    cache.key = ddp_cacheKey(file);
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:cache into:DDPSMBFileHashCache.className];
    #endif
}

- (NSString *)SMBFileHash:(TOSMBSessionFile *)file {
    
#if !DDPAPPTYPEISMAC
    NSString *key = ddp_cacheKey(file);
    WCTDatabase *db = [DDPCacheManager shareDB];
    DDPSMBFileHashCache *cache = [db getOneObjectOfClass:DDPSMBFileHashCache.class fromTable:DDPSMBFileHashCache.className where:DDPSMBFileHashCache.key == key];
    return cache.md5;
#else
    return @"";
#endif
}

#pragma mark -
- (NSArray<DDPCollectionCache *> *)collectors {
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getAllObjectsOfClass:DDPCollectionCache.class fromTable:DDPCollectionCache.className];
}

- (void)addCollector:(DDPCollectionCache *)cache {
    if (cache == nil) return;
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:cache into:DDPCollectionCache.className];
    for (id<DDPCacheManagerDelagate> observer in self.observers.copy) {
        if ([observer respondsToSelector:@selector(collectionDidHandleCache:operation:)]) {
            [observer collectionDidHandleCache:cache operation:DDPCollectionCacheDidChangeTypeAdd];
        }
    }
}

- (void)removeCollector:(DDPCollectionCache *)cache {
    if (cache == nil) return;
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db deleteObjectsFromTable:DDPCollectionCache.className where:DDPCollectionCache.cacheType == cache.cacheType && DDPCollectionCache.filePath == cache.filePath];
    
    for (id<DDPCacheManagerDelagate> observer in self.observers.copy) {
        if ([observer respondsToSelector:@selector(collectionDidHandleCache:operation:)]) {
            [observer collectionDidHandleCache:cache operation:DDPCollectionCacheDidChangeTypeRemove];
        }
    }
}

- (DDPUser *)_currentUser {
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getOneObjectOfClass:DDPUser.class fromTable:DDPUser.className orderBy:DDPUser.lastUpdateTime.order(WCTOrderedDescending)];
}

- (BOOL)_saveWithUser:(DDPUser *)user {
    if (user.identity == 0) {
        return false;
    }
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db insertOrReplaceObject:user into:DDPUser.className];
}

#pragma mark -
- (YYWebImageManager *)imageManagerWithRoundedCornersRadius:(CGFloat)radius {
    YYWebImageManager *manager = self.imageManagerDic[@(radius)];
    if (manager == nil) {
        NSString *cachePath = [UIApplication sharedApplication].cachesPath;
        cachePath = [cachePath stringByAppendingPathComponent:@"dandanplay"];
        cachePath = [cachePath stringByAppendingPathComponent:@"roundedCorners"];
        cachePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(radius)]];
        
        manager = [[YYWebImageManager alloc] initWithCache:[[YYImageCache alloc] initWithPath:cachePath] queue:nil];
        self.imageManagerDic[@(radius)] = manager;
    }
    return manager;
}


@end
