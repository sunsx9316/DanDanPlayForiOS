//
//  DDPCacheManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPCacheManager.h"
#import "UIFont+Tools.h"
#import <TOSMBSessionFile.h>
#import <TOSMBSessionDownloadTaskPrivate.h>
#import "DDPSMBFileHashCache.h"
#import "DDPCacheManager+multiply.h"

static NSString *const danmakuFiltersKey = @"danmaku_filters";
static NSString *const danmakuFontIsSystemFontKey = @"danmaku_font_is_system_font";
static NSString *const collectionCacheKey = @"collection_cache";
//static NSString *const userSaveKey = @"login_user";
//static NSString *const lastLoginUserKey = @"last_login_user";
//static NSString *const danmakuCacheTimeKey = @"damaku_cache_time";
//static NSString *const autoRequestThirdPartyDanmakuKey = @"auto_request_third_party_danmaku";
//static NSString *const openFastMatchKey = @"open_fast_match";
//static NSString *const danmakuFontKey = @"danmaku_font";
//static NSString *const danmakuOpacityKey = @"danmaku_opacity";
//static NSString *const danmakuShadowStyleKey = @"danmaku_shadow_style";
//static NSString *const subtitleProtectAreaKey = @"subtitle_protect_area";
//static NSString *const danmakuSpeedKey = @"danmaku_speed";
//static NSString *const playerPlayKey = @"player_play";
//static NSString *const folderCacheKey = @"folder_cache";
//static NSString *const SMBLoginKey = @"SMB_login";
//static NSString *const lastPlayTimeKey = @"last_play_time";
//static NSString *const openAutoDownloadSubtitleKey = @"open_auto_download_subtitle";
//static NSString *const priorityLoadLocalDanmakuKey = @"priority_load_local_danmaku";
//static NSString *const showDownloadStatusViewKey = @"show_down_load_status_view";
//static NSString *const sendDanmakuColorKey = @"send_danmaku_color";
//static NSString *const sendDanmakuModeKey = @"send_danmaku_mode";
//static NSString *const playInterfaceOrientationKey = @"play_interface_orientation";
//static NSString *const danmakuLimitCountKey = @"danmaku_limit_count";
//static NSString *const useTouchIdLoginKey = @"use_touch_id_login";

//NSString *const videoNameKey = @"video_name";
//NSString *const videoEpisodeIdKey = @"video_episode_id";


@interface DDPCacheManager ()<TOSMBSessionDownloadTaskDelegate>
@property (strong, nonatomic) YYCache *cache;
//@property (strong, nonatomic) YYCache *episodeInfoCache;
//@property (strong, nonatomic) YYCache *lastPlayTimeCache;
//@property (strong, nonatomic) YYCache *smbFileHashCache;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, YYWebImageManager *>*imageManagerDic;
//@property (strong, nonatomic) NSMutableArray <TOSMBSessionDownloadTask *>*aDownloadTasks;
@property (strong, nonatomic) NSMutableArray <DDPFilter *>*aFilterCollection;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSHashTable *observers;
@end

@implementation DDPCacheManager
{
//    NSHashTable *_observers;
    //已经接收的大小
    NSUInteger _totalAlreadyReceive;
}

+ (instancetype)shareCacheManager {
    static DDPCacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark - 懒加载
- (YYCache *)cache {
    if (_cache == nil) {
        _cache = [[YYCache alloc] initWithName:@"dandanplay_cache"];
    }
    return _cache;
}

//- (YYCache *)episodeInfoCache {
//    if (_episodeInfoCache == nil) {
//        _episodeInfoCache = [[YYCache alloc] initWithName:@"episode_info_cache"];
//    }
//    return _episodeInfoCache;
//}
//
//- (YYCache *)lastPlayTimeCache {
//    if (_lastPlayTimeCache == nil) {
//        _lastPlayTimeCache = [[YYCache alloc] initWithName:@"last_play_time_cache"];
//    }
//    return _lastPlayTimeCache;
//}
//
//- (YYCache *)smbFileHashCache {
//    if (_smbFileHashCache == nil) {
//        _smbFileHashCache = [[YYCache alloc] initWithName:@"smb_file_hash_cache"];
//    }
//    return _smbFileHashCache;
//}

- (NSMutableDictionary<NSNumber *,YYWebImageManager *> *)imageManagerDic {
    if (_imageManagerDic == nil) {
        _imageManagerDic = [NSMutableDictionary dictionary];
    }
    return _imageManagerDic;
}

- (NSHashTable *)observers {
    if (_observers == nil) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    }
    return _observers;
}


#pragma mark -
- (void)setUser:(DDPUser *)user {
    [self.cache setObject:user forKey:[self keyWithSEL:_cmd]];
}

- (DDPUser *)user {
    return (DDPUser *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
}

#pragma mark - 
- (void)setLastLoginUser:(DDPUser *)lastLoginUser {
    [self.cache setObject:lastLoginUser forKey:[self keyWithSEL:_cmd]];
}

- (DDPUser *)lastLoginUser {
    return (DDPUser *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
}

#pragma mark - 
- (void)setDanmakuFont:(UIFont *)danmakuFont {
    [self.cache setObject:danmakuFont forKey:[self keyWithSEL:_cmd] withBlock:nil];
    [self.cache setObject:@(danmakuFont.isSystemFont) forKey:danmakuFontIsSystemFontKey withBlock:nil];
}

- (UIFont *)danmakuFont {
    UIFont *font = (UIFont *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (font == nil) {
        font = [UIFont ddp_normalSizeFont];
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
    [self.cache setObject:@(danmakuShadowStyle) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (JHDanmakuShadowStyle)danmakuShadowStyle {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(JHDanmakuShadowStyleGlow);
        self.danmakuShadowStyle = JHDanmakuShadowStyleGlow;
    }
    return [num integerValue];
}

#pragma mark - 
- (void)setSubtitleProtectArea:(BOOL)subtitleProtectArea {
    [self.cache setObject:@(subtitleProtectArea) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (BOOL)subtitleProtectArea {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.subtitleProtectArea = YES;
    }
    return [num boolValue];
}

#pragma mark -
- (void)setDanmakuCacheTime:(NSUInteger)danmakuCacheTime {
    [self.cache setObject:@(danmakuCacheTime) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (NSUInteger)danmakuCacheTime {
    NSNumber *time = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (time == nil) {
        time = @(7);
        self.danmakuCacheTime = 7;
    }
    
    return [time unsignedIntegerValue];
}

#pragma mark -
- (void)setAutoRequestThirdPartyDanmaku:(BOOL)autoRequestThirdPartyDanmaku {
    [self.cache setObject:@(autoRequestThirdPartyDanmaku) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (BOOL)autoRequestThirdPartyDanmaku {
    NSNumber *autoRequestThirdPartyDanmaku = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (autoRequestThirdPartyDanmaku == nil) {
        autoRequestThirdPartyDanmaku = @(YES);
        self.autoRequestThirdPartyDanmaku = YES;
    }
    
    return [autoRequestThirdPartyDanmaku boolValue];
}

#pragma mark -
- (void)setOpenFastMatch:(BOOL)openFastMatch {
    [self.cache setObject:@(openFastMatch) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (BOOL)openFastMatch {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.openFastMatch = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setOpenAutoDownloadSubtitle:(BOOL)openAutoDownloadSubtitle {
    [self.cache setObject:@(openAutoDownloadSubtitle) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (BOOL)openAutoDownloadSubtitle {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.openAutoDownloadSubtitle = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setUseTouchIdLogin:(BOOL)useTouchIdLogin {
    [self.cache setObject:@(useTouchIdLogin) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (BOOL)useTouchIdLogin {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.useTouchIdLogin = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setPriorityLoadLocalDanmaku:(BOOL)priorityLoadLocalDanmaku {
    [self.cache setObject:@(priorityLoadLocalDanmaku) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (BOOL)priorityLoadLocalDanmaku {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.priorityLoadLocalDanmaku = YES;
    }
    return num.boolValue;
}



#pragma mark -
- (void)setPlayMode:(DDPPlayerPlayMode)playMode {
    [self.cache setObject:@(playMode) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (DDPPlayerPlayMode)playMode {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPPlayerPlayModeOrder);
        self.playMode = DDPPlayerPlayModeOrder;
    }
    
    return num.integerValue;
}

#pragma mark - 
- (float)danmakuSpeed {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @1;
        self.danmakuSpeed = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuSpeed:(float)danmakuSpeed {
    [self.cache setObject:@(danmakuSpeed) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

#pragma mark -
- (float)danmakuOpacity {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @1;
        self.danmakuOpacity = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuOpacity:(float)danmakuOpacity {
    [self.cache setObject:@(danmakuOpacity) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

#pragma mark -
- (UIColor *)sendDanmakuColor {
    UIColor *color = (UIColor *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (color == nil) {
        color = [UIColor whiteColor];
        self.sendDanmakuColor = color;
    }
    return color;
}

- (void)setSendDanmakuColor:(UIColor *)sendDanmakuColor {
    [self.cache setObject:sendDanmakuColor forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (DDPDanmakuMode)sendDanmakuMode {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPDanmakuModeNormal);
        self.sendDanmakuMode = DDPDanmakuModeNormal;
    }
    
    return num.integerValue;
}

- (void)setSendDanmakuMode:(DDPDanmakuMode)sendDanmakuMode {
    [self.cache setObject:@(sendDanmakuMode) forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (NSUInteger)danmakuLimitCount {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(14);
        self.danmakuLimitCount = 14;
    }
    
    return num.integerValue;
}

- (void)setDanmakuLimitCount:(NSUInteger)danmakuLimitCount {
    [self.cache setObject:@(danmakuLimitCount) forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (void)setPlayInterfaceOrientation:(UIInterfaceOrientation)playInterfaceOrientation {
    [self.cache setObject:@(playInterfaceOrientation) forKey:[self keyWithSEL:_cmd]];
}

- (UIInterfaceOrientation)playInterfaceOrientation {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(UIInterfaceOrientationLandscapeRight);
        self.playInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
    }
    
    return num.integerValue;
}

- (DDPDanmakuShieldType)danmakuShieldType {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPDanmakuShieldTypeNone);
        self.danmakuShieldType = DDPDanmakuShieldTypeNone;
    }
    
    return num.integerValue;
}

- (void)setDanmakuShieldType:(DDPDanmakuShieldType)danmakuShieldType {
    [self.cache setObject:@(danmakuShieldType) forKey:[self keyWithSEL:_cmd]];
}

- (void)setUserDefineRequestDomain:(NSString *)userDefineRequestDomain {
    [self.cache setObject:userDefineRequestDomain forKey:[self keyWithSEL:_cmd]];
}

- (NSString *)userDefineRequestDomain {
    NSString *path = (NSString *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    return path;
}

#pragma mark -
- (NSMutableDictionary *)folderCache {
    NSMutableDictionary <NSString *, NSArray <NSString *>*>*dic = (NSMutableDictionary *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    
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
    [self.cache setObject:folderCache forKey:[self keyWithSEL:_cmd]];
}

#pragma mark - 私有方法
- (NSString *)keyWithSEL:(SEL)aSEL {
    if (aSEL == nil) return nil;
    
    NSString *selName = NSStringFromSelector(aSEL);
    
    if ([selName hasPrefix:@"set"] && [selName hasSuffix:@":"] && selName.length > 4) {
        NSString *tempStr = [selName substringWithRange:NSMakeRange(3, selName.length - 4)];
        tempStr = [NSString stringWithFormat:@"%@%@", [tempStr substringToIndex:1].lowercaseString, [tempStr substringFromIndex:1]];
        return tempStr;
    }
    return NSStringFromSelector(aSEL);
}

@end
