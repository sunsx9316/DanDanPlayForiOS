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

//#import <TOSMBSessionFile.h>
//#import <TOSMBSessionDownloadTaskPrivate.h>

NS_INLINE NSString *ddp_cacheKey(TOSMBSessionFile *file) {
    return [NSString stringWithFormat:@"%@_%llu", file.name, file.fileSize];
};

@interface DDPCacheManager ()<TOSMBSessionTaskDelegate>

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
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getAllObjectsOfClass:DDPFilter.class fromTable:DDPFilter.className];
}

- (void)addFilter:(DDPFilter *)model {
    if (model) {
        [self addFilters:@[model]];
    }
}

- (void)removeFilter:(DDPFilter *)model {
    if (model) {
        [self removeFilter:model];
    }
}

- (void)addFilters:(NSArray<DDPFilter *> *)models {
    if (models.count == 0) return;
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObjects:models into:DDPFilter.className];
}

- (void)removeFilters:(NSArray<DDPFilter *> *)models {
    if (models.count == 0) return;
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    NSString *tableName = DDPFilter.className;
    [db runTransaction:^BOOL{
        for (DDPFilter *obj in models) {
            [db deleteObjectsFromTable:tableName where:DDPFilter.name == obj.name];
        }
        
        return YES;
    }];
}

- (NSArray<DDPLinkInfo *> *)linkInfoHistorys {
    WCTDatabase *db = [DDPCacheManager shareDB];
    NSArray *arr = [db getAllObjectsOfClass:DDPLinkInfo.class fromTable:DDPLinkInfo.className];
    return arr;
}

- (DDPLinkInfo *)lastLinkInfo {
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getOneObjectOfClass:DDPLinkInfo.class fromTable:DDPLinkInfo.className orderBy:DDPLinkInfo.saveTime.order(WCTOrderedDescending)];
}

- (void)addLinkInfo:(DDPLinkInfo *)linkInfo {
    if (linkInfo == nil) return;
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:linkInfo into:DDPLinkInfo.className];
}

- (void)removeLinkInfo:(DDPLinkInfo *)linkInfo {
    if (linkInfo == nil) return;
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db deleteObjectsFromTable:linkInfo.className where:DDPLinkInfo.selectedIpAdress == linkInfo.selectedIpAdress];
}

//- (void)addFilter:(DDPFilter *)model {
//    [self.aFilterCollection addObject:model];
//    [self.cache setObject:self.aFilterCollection forKey:danmakuFiltersKey];
//}
//
//- (void)addFilters:(NSArray <DDPFilter *>*)models {
//    [self.aFilterCollection addObjectsFromArray:models];
//    [self.cache setObject:self.aFilterCollection forKey:danmakuFiltersKey];
//}
//
//- (void)addFilters:(NSArray <DDPFilter *>*)models atHeader:(BOOL)atHeader {
//    if (atHeader) {
//        [self.aFilterCollection insertObjects:models atIndex:0];
//    }
//    else {
//        [self.aFilterCollection addObjectsFromArray:models];
//    }
//    [self.cache setObject:self.aFilterCollection forKey:danmakuFiltersKey];
//}
//
//- (void)removeFilter:(DDPFilter *)model {
//    [self.aFilterCollection removeObject:model];
//    [self.cache setObject:self.aFilterCollection forKey:danmakuFiltersKey];
//}
//
//- (void)removeFilters:(NSArray <DDPFilter *>*)models {
//    [self.aFilterCollection removeObjectsInArray:models];
//    [self.cache setObject:self.aFilterCollection forKey:danmakuFiltersKey];
//}
//
//- (void)updateFilter:(DDPFilter *)model {
//    NSInteger index = [self.aFilterCollection indexOfObject:model];
//    if (index != NSNotFound) {
//        [self.aFilterCollection replaceObjectAtIndex:index withObject:model];
//        [self.cache setObject:self.aFilterCollection forKey:danmakuFiltersKey];
//    }
//    else {
//        [self addFilter:model];
//    }
//}

//- (NSMutableArray<DDPFilter *> *)aFilterCollection {
//    if (_aFilterCollection == nil) {
//        _aFilterCollection = (NSMutableArray *)[self.cache objectForKey:danmakuFiltersKey];
//        
//        if (_aFilterCollection == nil) {
//            _aFilterCollection = [NSMutableArray array];
//            [self.cache setObject:_aFilterCollection forKey:danmakuFiltersKey];
//        }
//        
//        if ([_aFilterCollection isKindOfClass:[NSMutableArray class]] == NO) {
//            _aFilterCollection = [_aFilterCollection mutableCopy];
//        }
//    }
//    return _aFilterCollection;
//}

#pragma mark -
//- (void)relevanceCache:(DDPVideoCache *)cache toVideoModel:(DDPVideoModel *)model {
//    if (model.md5.length == 0 || cache == nil) return;
//
//    WCTDatabase *db = [DDPCacheManager shareDB];
//    cache.md5 = model.md5;
//    [db insertObject:cache into:DDPVideoCache.className];
//}

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

//- (NSDictionary *)episodeInfoWithVideoModel:(DDPVideoModel *)model {
//    if (model == nil) return nil;
//
//    return (NSDictionary *)[self.episodeInfoCache objectForKey:model.md5];
//}

//- (void)saveEpisodeId:(NSUInteger)episodeId
//          episodeName:(NSString *)episodeName
//           videoModel:(DDPVideoModel *)model {
//    if (model.md5.length == 0 || episodeId == 0) return;
//
//    if (episodeName.length == 0) {
//        episodeName = @"";
//    }
//
//    NSDictionary *dic = @{videoNameKey : episodeName , videoEpisodeIdKey : @(episodeId)};
//
//    [self.episodeInfoCache setObject:dic forKey:model.md5 withBlock:nil];
//}

//#pragma mark -

//- (void)saveLastPlayTime:(NSInteger)time videoModel:(DDPVideoModel *)model {
//    if (model == nil) return;
//    
//    for (id<DDPCacheManagerDelagate> observer in self.observers.copy) {
//        if ([observer respondsToSelector:@selector(lastPlayTimeWithVideoModel:time:)]) {
//            [observer lastPlayTimeWithVideoModel:model time:time];
//        }
//    }
//    
//    [self.lastPlayTimeCache setObject:@(time) forKey:model.quickHash];
//}
//
//- (NSInteger)lastPlayTimeWithVideoModel:(DDPVideoModel *)model {
//    NSNumber *num = (NSNumber *)[self.lastPlayTimeCache objectForKey:model.quickHash];
//    //不存在
//    if (num == nil) {
//        return -1;
//    }
//    return num.integerValue;
//}

#pragma mark -

//- (void)setSMBInfos:(NSArray<DDPSMBInfo *> *)SMBInfos {
//    [self.cache setObject:SMBInfos forKey:NSStringFromSelector(@selector(SMBInfos)) withBlock:nil];
//}

- (NSArray<DDPSMBInfo *> *)SMBLinkInfos {
    WCTDatabase *db = [DDPCacheManager shareDB];
    return [db getAllObjectsOfClass:DDPSMBInfo.class fromTable:DDPSMBInfo.className];
    //    NSArray *arr = (NSArray *)[self.cache objectForKey:NSStringFromSelector(_cmd)];
    //    if (arr == nil) {
    //        arr = [NSMutableArray array];
    //        self.SMBInfos = arr;
    //    }
    //
    //    if ([arr isKindOfClass:[NSMutableArray class]] == NO) {
    //        arr = [arr mutableCopy];
    //        self.SMBInfos = arr;
    //    }
    //    return arr;
}

- (void)saveSMBInfo:(DDPSMBInfo *)info {
    if (info == nil) return;
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:info into:DDPSMBInfo.className];
    
//    NSMutableArray *arr = (NSMutableArray *)self.SMBInfos;
//    if ([arr containsObject:info] == NO) {
//        [arr addObject:info];
//    }
//    else {
//        NSInteger index = [arr indexOfObject:info];
//        arr[index] = info;
//    }
//    self.SMBInfos = arr;
}

- (void)removeSMBInfo:(DDPSMBInfo *)info {
    if (info == nil) return;
     WCTDatabase *db = [DDPCacheManager shareDB];
    [db deleteObjectsFromTable:info.className where:DDPSMBInfo.hostName == info.hostName && DDPSMBInfo.userName == info.userName && DDPSMBInfo.password == info.password];
    
//    NSMutableArray *arr = (NSMutableArray *)self.SMBInfos;
//    NSInteger index = [arr indexOfObject:info];
//    if (index != NSNotFound) {
//        [arr removeObjectAtIndex:index];
//    }
//    self.SMBInfos = arr;
}

#pragma mark -
- (void)saveSMBFileHashWithHash:(NSString *)hash file:(TOSMBSessionFile *)file {
    if (file == nil) return;
    DDPSMBFileHashCache *cache = [[DDPSMBFileHashCache alloc] init];
    cache.md5 = hash;
    cache.date = [NSDate date];
    cache.key = ddp_cacheKey(file);
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    [db insertOrReplaceObject:cache into:DDPSMBFileHashCache.className];
//    [self.smbFileHashCache setObject:cache forKey:[NSString stringWithFormat:@"%@_%llu", file.name, file.fileSize]];
}

- (NSString *)SMBFileHash:(TOSMBSessionFile *)file {
    
    NSString *key = ddp_cacheKey(file);
    
    WCTDatabase *db = [DDPCacheManager shareDB];
    DDPSMBFileHashCache *cache = [db getOneObjectOfClass:DDPSMBFileHashCache.class fromTable:DDPSMBFileHashCache.className where:DDPSMBFileHashCache.key == key];
    return cache.md5;
    
//    DDPSMBFileHashCache *cache = (DDPSMBFileHashCache *)[self.smbFileHashCache objectForKey:key];
//    //兼容旧数据
//    if ([cache isKindOfClass:[DDPSMBFileHashCache class]] == NO) {
//        [self.smbFileHashCache setObject:nil forKey:key];
//        return nil;
//    }
//    //缓存过期
//    else if(fabs([[NSDate date] timeIntervalSinceDate:cache.date]) > 7 * 24 * 3600) {
//        [self.smbFileHashCache setObject:nil forKey:key];
//        return nil;
//    }
//
//    return cache.md5;
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
    
//    if ([self.collectionList containsObject:cache]) return DDPErrorWithCode(DDPErrorCodeObjectExist);
    
//    [self.collectionList addObject:cache];
//    [self.cache setObject:self.collectionList forKey:collectionCacheKey];
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
    
//    [self.collectionList removeObject:cache];
//    [self.cache setObject:self.collectionList forKey:collectionCacheKey];
    for (id<DDPCacheManagerDelagate> observer in self.observers.copy) {
        if ([observer respondsToSelector:@selector(collectionDidHandleCache:operation:)]) {
            [observer collectionDidHandleCache:cache operation:DDPCollectionCacheDidChangeTypeRemove];
        }
    }
}

//#pragma mark -
//+ (NSUInteger)cacheSize {
//    DDPCacheManager *manager = [DDPCacheManager shareCacheManager];
//    NSInteger size = [manager.episodeInfoCache.diskCache totalCost];
//    size += [manager.lastPlayTimeCache.diskCache totalCost];
//    size += [manager.smbFileHashCache.diskCache totalCost];
//    return size;
//}
//
//+ (void)removeAllCache {
//    DDPCacheManager *manager = [DDPCacheManager shareCacheManager];
//    [manager.episodeInfoCache.diskCache removeAllObjects];
//    [manager.lastPlayTimeCache.diskCache removeAllObjects];
//    [manager.smbFileHashCache.diskCache removeAllObjects];
//}


//- (void)addSMBSessionDownloadTask:(TOSMBSessionDownloadTask *)task {
//    if (task == nil) return;
//    
//    [self addSMBSessionDownloadTasks:@[task]];
//}

//- (void)addSMBSessionDownloadTasks:(NSArray <TOSMBSessionDownloadTask *>*)tasks {
//    if (tasks.count == 0) return;
//
//    [tasks enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        //        [obj setValue:self forKey:@"delegate"];
//        obj.delegate = self;
////        _totoalExpectedToReceive += obj.countOfBytesExpectedToReceive;
//    }];
//
//    [self.aDownloadTasks addObjectsFromArray:tasks];
//    for (id<DDPCacheManagerDelagate> observer in self.observers.copy) {
//        if ([observer respondsToSelector:@selector(SMBDownloadTasksDidChange:type:)]) {
//            [observer SMBDownloadTasksDidChange:self.aDownloadTasks type:SMBDownloadTasksDidChangeTypeAdd];
//        }
//    }
//}
//
//- (void)removeSMBSessionDownloadTasks:(NSArray <TOSMBSessionDownloadTask *>*)tasks {
//    [self removeSMBSessionDownloadTasks:tasks byUser:YES];
//}
//
//- (void)removeSMBSessionDownloadTask:(TOSMBSessionDownloadTask *)task {
//    if (task == nil) return;
//    [self removeSMBSessionDownloadTasks:@[task] byUser:YES];
//}
//
//- (void)removeSMBSessionDownloadTasks:(NSArray <TOSMBSessionDownloadTask *>*)tasks byUser:(BOOL)byUser {
//    if (tasks.count == 0) return;
//
//    if (byUser) {
//        [tasks enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            _totoalExpectedToReceive -= obj.countOfBytesExpectedToReceive;
//        }];
//    }
//
//    [self.aDownloadTasks removeObjectsInArray:tasks];
//    for (id<DDPCacheManagerDelagate> observer in _observers.copy) {
//        if ([observer respondsToSelector:@selector(SMBDownloadTasksDidChange:type:)]) {
//            [observer SMBDownloadTasksDidChange:self.aDownloadTasks type:SMBDownloadTasksDidChangeTypeRemove];
//        }
//    }
//
//    //全部下载完成
//    if (self.aDownloadTasks.count == 0) {
//        _totoalExpectedToReceive = 0;
//        _totalAlreadyReceive = 0;
//
//        for (id<DDPCacheManagerDelagate> observer in _observers.copy) {
//            if ([observer respondsToSelector:@selector(SMBDownloadTasksDidDownloadCompletion)]) {
//                [observer SMBDownloadTasksDidDownloadCompletion];
//            }
//        }
//    }
//}
//
//- (NSArray <TOSMBSessionDownloadTask *>*)downloadTasks {
//    return self.aDownloadTasks;
//}
//
//- (NSMutableArray<TOSMBSessionDownloadTask *> *)aDownloadTasks {
//    if (_aDownloadTasks == nil) {
//        _aDownloadTasks = [NSMutableArray array];
//    }
//    return _aDownloadTasks;
//}

//- (NSUInteger)totoalToReceive {
//    __block NSUInteger _receive = 0;
//    
//    [self.aDownloadTasks enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        _receive += obj.countOfBytesReceived;
//    }];
//    
//    return _totalAlreadyReceive + _receive;
//}

//#pragma mark TOSMBSessionDownloadTaskDelegate
//
//- (void)downloadTask:(TOSMBSessionDownloadTask *)downloadTask didFinishDownloadingToPath:(NSString *)destinationPath {
//
//    if (downloadTask) {
//        _totalAlreadyReceive += downloadTask.countOfBytesExpectedToReceive;
//        //移除下载成功的任务
//        [self removeSMBSessionDownloadTasks:@[downloadTask] byUser:NO];
//    }
//    //刷新本地列表
//    [[NSNotificationCenter defaultCenter] postNotificationName:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
//}
//
//#pragma mark -
//- (BOOL)timerIsStart {
//    return _timer != nil;
//}
//
//- (void)addLinkDownload {
//    //开启计时器 更新任务数量
//    if (_timer == nil) {
//        self.timer.fireDate = [NSDate distantPast];
//    }
//}
//
//- (void)updateLinkDownloadInfo {
//    if ([DDPCacheManager shareCacheManager].linkInfo == nil) return;
//
//    [DDPLinkNetManagerOperation linkDownloadListWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress completionHandler:^(DDPLinkDownloadTaskCollection *responseObject, NSError *error) {
//        __block NSUInteger linkTotoalExpectedToReceive = 0;
//        __block NSUInteger linkTotoalToReceive = 0;
//        __block NSUInteger linkDownloadingTaskCount = 0;
//
//        [responseObject.collection enumerateObjectsUsingBlock:^(DDPLinkDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            linkTotoalExpectedToReceive += obj.totalBytes;
//            linkTotoalToReceive += obj.downloadedBytes;
//            if (obj.state != DDPLinkDownloadTaskStateMaskTorrent) {
//                linkDownloadingTaskCount++;
//            }
//        }];
//
//        self.linkDownloadingTaskCount = linkDownloadingTaskCount;
//
//        if (linkTotoalToReceive >= linkTotoalExpectedToReceive) {
//            self.linkDownloadingTaskCount = 0;
//            [self.timer invalidate];
//            self.timer = nil;
//        }
//    }];
//}
//
//- (NSTimer *)timer {
//    if (_timer == nil) {
//        @weakify(self)
//        _timer = [NSTimer timerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
//            @strongify(self)
//            if (!self) return;
//
//            [self updateLinkDownloadInfo];
//        } repeats:YES];
//        _timer.fireDate = [NSDate distantFuture];
//        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    }
//    return _timer;
//}

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
