//
//  CacheManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "CacheManager.h"
#import "UIFont+Tools.h"
#import <TOSMBSessionFile.h>
#import <TOSMBSessionDownloadTaskPrivate.h>

static NSString *const userSaveKey = @"login_user";
static NSString *const danmakuCacheTimeKey = @"damaku_cache_time";
static NSString *const autoRequestThirdPartyDanmakuKey = @"auto_request_third_party_danmaku";
static NSString *const danmakuFiltersKey = @"danmaku_filters";
static NSString *const openFastMatchKey = @"open_fast_match";
static NSString *const danmakuFontKey = @"danmaku_font";
static NSString *const danmakuOpacityKey = @"danmaku_opacity";
static NSString *const danmakuFontIsSystemFontKey = @"danmaku_font_is_system_font";
static NSString *const danmakuShadowStyleKey = @"danmaku_shadow_style";
static NSString *const subtitleProtectAreaKey = @"subtitle_protect_area";
static NSString *const danmakuSpeedKey = @"danmaku_speed";
static NSString *const playerPlayKey = @"player_play";
static NSString *const folderCacheKey = @"folder_cache";
static NSString *const SMBLoginKey = @"SMB_login";
static NSString *const lastPlayTimeKey = @"last_play_time";
static NSString *const openAutoDownloadSubtitleKey = @"open_auto_download_subtitle";
static NSString *const priorityLoadLocalDanmakuKey = @"priority_load_local_danmaku";
static NSString *const showDownloadStatusViewKey = @"show_down_load_status_view";

NSString *const videoNameKey = @"video_name";
NSString *const videoEpisodeIdKey = @"video_episode_id";


@interface CacheManager ()<TOSMBSessionDownloadTaskDelegate>
@property (strong, nonatomic) YYCache *cache;
@property (strong, nonatomic) YYCache *episodeInfoCache;
@property (strong, nonatomic) YYCache *lastPlayTimeCache;
@property (strong, nonatomic) YYCache *smbFileHashCache;
@property (strong, nonatomic) NSMutableArray <TOSMBSessionDownloadTask *>*aDownloadTasks;
@end

@implementation CacheManager
{
    NSHashTable *_observers;
    //已经接收的大小
    NSUInteger _totalAlreadyReceive;
}

+ (instancetype)shareCacheManager {
    static CacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    }
    return self;
}

#pragma mark - 懒加载
- (YYCache *)cache {
    if (_cache == nil) {
        _cache = [[YYCache alloc] initWithName:@"dandanplay_cache"];
    }
    return _cache;
}

- (YYCache *)episodeInfoCache {
    if (_episodeInfoCache == nil) {
        _episodeInfoCache = [[YYCache alloc] initWithName:@"episode_info_cache"];
    }
    return _episodeInfoCache;
}

- (YYCache *)lastPlayTimeCache {
    if (_lastPlayTimeCache == nil) {
        _lastPlayTimeCache = [[YYCache alloc] initWithName:@"last_play_time_cache"];
    }
    return _lastPlayTimeCache;
}

- (YYCache *)smbFileHashCache {
    if (_smbFileHashCache == nil) {
        _smbFileHashCache = [[YYCache alloc] initWithName:@"smb_file_hash_cache"];
    }
    return _smbFileHashCache;
}


#pragma mark -
- (void)setUser:(JHUser *)user {
    [self.cache setObject:user forKey:userSaveKey withBlock:nil];
}

- (JHUser *)user {
    return (JHUser *)[self.cache objectForKey:userSaveKey];
}

#pragma mark -
- (JHFile *)rootFile {
    if (_rootFile == nil) {
        _rootFile = [[JHFile alloc] initWithFileURL:[[UIApplication sharedApplication] documentsURL] type:JHFileTypeFolder];
    }
    return _rootFile;
}

#pragma mark - 
- (DownloadStatusView *)downloadView {
    if (_downloadView == nil) {
        _downloadView = [[DownloadStatusView alloc] init];
        _downloadView.hidden = !self.showDownloadStatusView;
        [self addObserver:(DownloadStatusView <CacheManagerDelagate>*)_downloadView];
    }
    return _downloadView;
}

#pragma mark - 
- (void)setDanmakuFont:(UIFont *)danmakuFont {
    [self.cache setObject:danmakuFont forKey:danmakuFontKey withBlock:nil];
    [self.cache setObject:@(danmakuFont.isSystemFont) forKey:danmakuFontIsSystemFontKey withBlock:nil];
}

- (UIFont *)danmakuFont {
    UIFont *font = (UIFont *)[self.cache objectForKey:danmakuFontKey];
    if (font == nil) {
        font = NORMAL_SIZE_FONT;
        font.isSystemFont = YES;
        self.danmakuFont = font;
    }
    else {
        NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuFontIsSystemFontKey];
        font.isSystemFont = num.boolValue;
    }
    
    return font;
}

#pragma mark - 
- (void)setDanmakuShadowStyle:(JHDanmakuShadowStyle)danmakuShadowStyle {
    [self.cache setObject:@(danmakuShadowStyle) forKey:danmakuShadowStyleKey withBlock:nil];
}

- (JHDanmakuShadowStyle)danmakuShadowStyle {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuShadowStyleKey];
    if (num == nil) {
        num = @(JHDanmakuShadowStyleGlow);
        self.danmakuShadowStyle = JHDanmakuShadowStyleGlow;
    }
    return [num integerValue];
}

#pragma mark - 
- (void)setSubtitleProtectArea:(BOOL)subtitleProtectArea {
    [self.cache setObject:@(subtitleProtectArea) forKey:subtitleProtectAreaKey withBlock:nil];
}

- (BOOL)subtitleProtectArea {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:subtitleProtectAreaKey];
    if (num == nil) {
        num = @(YES);
        self.subtitleProtectArea = YES;
    }
    return [num boolValue];
}

#pragma mark -
- (void)setDanmakuCacheTime:(NSUInteger)danmakuCacheTime {
    [self.cache setObject:@(danmakuCacheTime) forKey:danmakuCacheTimeKey withBlock:nil];
}

- (NSUInteger)danmakuCacheTime {
    NSNumber *time = (NSNumber *)[self.cache objectForKey:danmakuCacheTimeKey];
    if (time == nil) {
        time = @(7);
        self.danmakuCacheTime = 7;
    }
    
    return [time unsignedIntegerValue];
}

#pragma mark -
- (void)setAutoRequestThirdPartyDanmaku:(BOOL)autoRequestThirdPartyDanmaku {
    [self.cache setObject:@(autoRequestThirdPartyDanmaku) forKey:autoRequestThirdPartyDanmakuKey withBlock:nil];
}

- (BOOL)autoRequestThirdPartyDanmaku {
    NSNumber *autoRequestThirdPartyDanmaku = (NSNumber *)[self.cache objectForKey:autoRequestThirdPartyDanmakuKey];
    if (autoRequestThirdPartyDanmaku == nil) {
        autoRequestThirdPartyDanmaku = @(YES);
        self.autoRequestThirdPartyDanmaku = YES;
    }
    
    return [autoRequestThirdPartyDanmaku boolValue];
}

#pragma mark -
- (void)setOpenFastMatch:(BOOL)openFastMatch {
    [self.cache setObject:@(openFastMatch) forKey:openFastMatchKey withBlock:nil];
}

- (BOOL)openFastMatch {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:openFastMatchKey];
    if (num == nil) {
        num = @(YES);
        self.openFastMatch = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setOpenAutoDownloadSubtitle:(BOOL)openAutoDownloadSubtitle {
    [self.cache setObject:@(openAutoDownloadSubtitle) forKey:openAutoDownloadSubtitleKey withBlock:nil];
}

- (BOOL)openAutoDownloadSubtitle {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:openAutoDownloadSubtitleKey];
    if (num == nil) {
        num = @(YES);
        self.openAutoDownloadSubtitle = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setPriorityLoadLocalDanmaku:(BOOL)priorityLoadLocalDanmaku {
    [self.cache setObject:@(priorityLoadLocalDanmaku) forKey:priorityLoadLocalDanmakuKey withBlock:nil];
}

- (BOOL)priorityLoadLocalDanmaku {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:priorityLoadLocalDanmakuKey];
    if (num == nil) {
        num = @(NO);
        self.priorityLoadLocalDanmaku = NO;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setShowDownloadStatusView:(BOOL)showDownloadStatusView {
    self.downloadView.hidden = !showDownloadStatusView;
    [self.cache setObject:@(showDownloadStatusView) forKey:showDownloadStatusViewKey withBlock:nil];
}

- (BOOL)showDownloadStatusView {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:showDownloadStatusViewKey];
    if (num == nil) {
        num = @(YES);
        self.showDownloadStatusView = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (NSDictionary *)episodeInfoWithVideoModel:(VideoModel *)model {
    if (model == nil) return nil;
    
    return (NSDictionary *)[self.episodeInfoCache objectForKey:model.md5];
}

- (void)saveEpisodeId:(NSUInteger)episodeId
          episodeName:(NSString *)episodeName
           videoModel:(VideoModel *)model {
    if (model.md5.length == 0 || episodeId == 0) return;
    
    if (episodeName.length == 0) {
        episodeName = @"";
    }
    
    NSDictionary *dic = @{videoNameKey : episodeName , videoEpisodeIdKey : @(episodeId)};
    
    [self.episodeInfoCache setObject:dic forKey:model.md5 withBlock:nil];
}

#pragma mark -
- (void)setPlayMode:(PlayerPlayMode)playMode {
    [self.cache setObject:@(playMode) forKey:playerPlayKey withBlock:nil];
}

- (PlayerPlayMode)playMode {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:playerPlayKey];
    if (num == nil) {
        num = @(PlayerPlayModeOrder);
        self.playMode = PlayerPlayModeOrder;
    }
    
    return num.integerValue;
}

#pragma mark - 
- (float)danmakuSpeed {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuSpeedKey];
    if (num == nil) {
        num = @1;
        self.danmakuSpeed = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuSpeed:(float)danmakuSpeed {
    [self.cache setObject:@(danmakuSpeed) forKey:danmakuSpeedKey withBlock:nil];
}

#pragma mark -
- (float)danmakuOpacity {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuOpacityKey];
    if (num == nil) {
        num = @1;
        self.danmakuOpacity = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuOpacity:(float)danmakuOpacity {
    [self.cache setObject:@(danmakuOpacity) forKey:danmakuOpacityKey withBlock:nil];
}

#pragma mark -
- (NSMutableDictionary *)folderCache {
    NSMutableDictionary <NSString *, NSArray <NSString *>*>*dic = (NSMutableDictionary *)[self.cache objectForKey:folderCacheKey];
    
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    if ([dic isKindOfClass:[NSMutableDictionary class]] == NO) {
        dic = [dic mutableCopy];
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
            dic[key] = [obj mutableCopy];
        }];
    }
    return dic;
}

- (void)setFolderCache:(NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *)folderCache {
    [self.cache setObject:folderCache forKey:folderCacheKey withBlock:nil];
}

#pragma mark -
- (NSArray<JHFilter *> *)danmakuFilters {
    return (NSArray *)[self.cache objectForKey:danmakuFiltersKey];
}

- (void)addDanmakuFilter:(JHFilter *)danmakuFilter {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:(NSArray *)[self.cache objectForKey:danmakuFiltersKey]];
    [arr addObject:danmakuFilter];
    [self.cache setObject:arr forKey:danmakuFiltersKey withBlock:nil];
}

- (void)removeDanmakuFilter:(JHFilter *)danmakuFilter {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:(NSArray *)[self.cache objectForKey:danmakuFiltersKey]];
    [arr removeObject:danmakuFilter];
    [self.cache setObject:arr forKey:danmakuFiltersKey withBlock:nil];
}

#pragma mark -

- (void)saveLastPlayTime:(NSInteger)time videoModel:(VideoModel *)model {
    if (model == nil) return;
    
    [self.lastPlayTimeCache setObject:@(time) forKey:model.quickHash];
}

- (NSInteger)lastPlayTimeWithVideoModel:(VideoModel *)model {
    NSNumber *num = (NSNumber *)[self.lastPlayTimeCache objectForKey:model.quickHash];
    //不存在
    if (num == nil) {
        return -1;
    }
    return num.integerValue;
}

#pragma mark -

- (void)setSMBInfos:(NSArray<JHSMBInfo *> *)SMBInfos {
    [self.cache setObject:SMBInfos forKey:SMBLoginKey withBlock:nil];
}

- (NSArray<JHSMBInfo *> *)SMBInfos {
    NSArray *arr = (NSArray *)[self.cache objectForKey:SMBLoginKey];
    if (arr == nil) {
        arr = [NSMutableArray array];
        self.SMBInfos = arr;
    }
    
    if ([arr isKindOfClass:[NSMutableArray class]] == NO) {
        arr = [arr mutableCopy];
        self.SMBInfos = arr;
    }
    return arr;
}

- (void)saveSMBInfo:(JHSMBInfo *)info {
    NSMutableArray *arr = (NSMutableArray *)[self.cache objectForKey:SMBLoginKey];
    if ([arr containsObject:info] == NO) {
        [arr addObject:info];
        self.SMBInfos = arr;        
    }
}

- (void)removeSMBInfo:(JHSMBInfo *)info {
    NSMutableArray *arr = (NSMutableArray *)[self.cache objectForKey:SMBLoginKey];
    [arr removeObject:info];
    self.SMBInfos = arr;
}

#pragma mark -
- (void)saveSMBFileHashWithHash:(NSString *)hash file:(TOSMBSessionFile *)file {
    if (file == nil) return;
    [self.smbFileHashCache setObject:hash forKey:[NSString stringWithFormat:@"%@_%llu", file.name, file.fileSize]];
}

- (NSString *)SMBFileHash:(TOSMBSessionFile *)file {
    return (NSString *)[self.smbFileHashCache objectForKey:[NSString stringWithFormat:@"%@_%llu", file.name, file.fileSize]];
}

#pragma mark - 
+ (NSUInteger)cacheSize {
    CacheManager *manager = [CacheManager shareCacheManager];
    NSInteger size = [manager.episodeInfoCache.diskCache totalCost];
    size += [manager.lastPlayTimeCache.diskCache totalCost];
    size += [manager.smbFileHashCache.diskCache totalCost];
    return size;
}

+ (void)removeAllCache {
    CacheManager *manager = [CacheManager shareCacheManager];
    [manager.episodeInfoCache.diskCache removeAllObjects];
    [manager.lastPlayTimeCache.diskCache removeAllObjects];
    [manager.smbFileHashCache.diskCache removeAllObjects];
}

#pragma mark - 

- (void)addObserver:(id<CacheManagerDelagate>)observer {
    if (!observer) return;
    [_observers addObject:observer];
}

- (void)removeObserver:(id<CacheManagerDelagate>)observer {
    if (!observer) return;
    [_observers removeObject:observer];
}

- (void)addSMBSessionDownloadTask:(TOSMBSessionDownloadTask *)task {
    if (task == nil) return;
    
    [self addSMBSessionDownloadTasks:@[task]];
}

- (void)addSMBSessionDownloadTasks:(NSArray <TOSMBSessionDownloadTask *>*)tasks {
    if (tasks.count == 0) return;
    
    [tasks enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = self;
        _totoalExpectedToReceive += obj.countOfBytesExpectedToReceive;
    }];
    
    [self.aDownloadTasks addObjectsFromArray:tasks];
    for (id<CacheManagerDelagate> observer in _observers.copy) {
        if ([observer respondsToSelector:@selector(SMBDownloadTasksDidChange:type:)]) {
            [observer SMBDownloadTasksDidChange:self.aDownloadTasks type:SMBDownloadTasksDidChangeTypeAdd];
        }
    }
}

- (void)removeSMBSessionDownloadTasks:(NSArray <TOSMBSessionDownloadTask *>*)tasks {
    [self removeSMBSessionDownloadTasks:tasks byUser:YES];
}

- (void)removeSMBSessionDownloadTask:(TOSMBSessionDownloadTask *)task {
    if (task == nil) return;
    [self removeSMBSessionDownloadTasks:@[task] byUser:YES];
}

- (void)removeSMBSessionDownloadTasks:(NSArray <TOSMBSessionDownloadTask *>*)tasks byUser:(BOOL)byUser {
    if (tasks.count == 0) return;
    
    if (byUser) {
        [tasks enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _totoalExpectedToReceive -= obj.countOfBytesExpectedToReceive;
        }];
    }
    
    [self.aDownloadTasks removeObjectsInArray:tasks];
    for (id<CacheManagerDelagate> observer in _observers.copy) {
        if ([observer respondsToSelector:@selector(SMBDownloadTasksDidChange:type:)]) {
            [observer SMBDownloadTasksDidChange:self.aDownloadTasks type:SMBDownloadTasksDidChangeTypeRemove];
        }
    }
    
    //全部下载完成
    if (self.aDownloadTasks.count == 0) {
        _totoalExpectedToReceive = 0;
        _totalAlreadyReceive = 0;
        
        for (id<CacheManagerDelagate> observer in _observers.copy) {
            if ([observer respondsToSelector:@selector(SMBDownloadTasksDidDownloadCompletion)]) {
                [observer SMBDownloadTasksDidDownloadCompletion];
            }
        }
    }
}

- (NSArray <TOSMBSessionDownloadTask *>*)downloadTasks {
    return self.aDownloadTasks;
}

- (NSMutableArray<TOSMBSessionDownloadTask *> *)aDownloadTasks {
    if (_aDownloadTasks == nil) {
        _aDownloadTasks = [NSMutableArray array];
    }
    return _aDownloadTasks;
}

- (NSUInteger)totoalToReceive {
    __block NSUInteger _receive = 0;
    
    [self.aDownloadTasks enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _receive += obj.countOfBytesReceived;
    }];
    
    return _totalAlreadyReceive + _receive;
}

#pragma mark TOSMBSessionDownloadTaskDelegate

- (void)downloadTask:(TOSMBSessionDownloadTask *)downloadTask didFinishDownloadingToPath:(NSString *)destinationPath {
    
    if (downloadTask) {
        _totalAlreadyReceive += downloadTask.countOfBytesExpectedToReceive;
        //移除下载成功的任务
        [self removeSMBSessionDownloadTasks:@[downloadTask] byUser:NO];
    }
    //刷新本地列表
    [[NSNotificationCenter defaultCenter] postNotificationName:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
}

@end
