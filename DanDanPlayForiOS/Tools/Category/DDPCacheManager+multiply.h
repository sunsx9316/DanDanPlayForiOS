//
//  DDPCacheManager+multiply.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCacheManager.h"
#import "DDPVideoCache.h"

@interface DDPCacheManager (multiply)

- (void)addObserver:(id<DDPCacheManagerDelagate>)observer;
- (void)removeObserver:(id<DDPCacheManagerDelagate>)observer;

/**
 弹幕过滤
 */
@property (strong, nonatomic, readonly) NSArray <DDPFilter *>*danmakuFilters;

/**
 当前过滤列表的hash值
 */
@property (assign, nonatomic, readonly) UInt64 filterHash;
- (void)addFilter:(DDPFilter *)model;
- (void)removeFilter:(DDPFilter *)model;

- (void)addFilters:(NSArray <DDPFilter *>*)models;
- (void)removeFilters:(NSArray <DDPFilter *>*)models;


@property (strong, nonatomic, readonly) NSArray <DDPLinkInfo *>*linkInfoHistorys;

/**
 最近一次连接的pc
 */
@property (strong, nonatomic, readonly) DDPLinkInfo *lastLinkInfo;

- (void)addLinkInfo:(DDPLinkInfo *)linkInfo;
- (void)removeLinkInfo:(DDPLinkInfo *)linkInfo;


/**
 获取缓存的视频信息
 
 @param model 视频
 @return 缓存
 */
- (DDPVideoCache *)relevanceCacheWithVideoModel:(DDPVideoModel *)model;

- (void)saveEpisodeId:(NSUInteger)episodeId episodeName:(NSString *)episodeName videoModel:(DDPVideoModel *)model;
//存储上次播放时间
- (void)saveLastPlayTime:(NSInteger)time videoModel:(DDPVideoModel *)model;

/**
 smb共享登录信息
 */
@property (strong, nonatomic, readonly) NSArray <DDPSMBInfo *>*SMBLinkInfos;
- (void)saveSMBInfo:(DDPSMBInfo *)info;
- (void)removeSMBInfo:(DDPSMBInfo *)info;


/**
 保存smb文件Hash
 
 @param hash hash
 @param file smb文件
 */
- (void)saveSMBFileHashWithHash:(NSString *)hash file:(TOSMBSessionFile *)file;

/**
 获取smb文件hash
 
 @param file smb文件
 @return hash
 */
- (NSString *)SMBFileHash:(TOSMBSessionFile *)file;


@property (strong, nonatomic, readonly) NSArray <DDPCollectionCache *>*collectors;
- (void)addCollector:(DDPCollectionCache *)cache;
- (void)removeCollector:(DDPCollectionCache *)cache;

- (YYWebImageManager *)imageManagerWithRoundedCornersRadius:(CGFloat)radius;

- (DDPUser *)_currentUser;
- (BOOL)_saveWithUser:(DDPUser *)user;

@end
