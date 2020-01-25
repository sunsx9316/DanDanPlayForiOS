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
#import "DDPBaseNetManager.h"
#import "DDPSharedNetManager.h"
#import "DDPMediaPlayer.h"

static NSString *const danmakuFiltersKey = @"danmaku_filters";
static NSString *const danmakuFontIsSystemFontKey = @"danmaku_font_is_system_font";
static NSString *const collectionCacheKey = @"collection_cache";


@interface DDPCacheManager ()<TOSMBSessionDownloadTaskDelegate>
@property (strong, nonatomic) YYCache *cache;

@property (strong, nonatomic) NSMutableDictionary <NSNumber *, YYWebImageManager *>*imageManagerDic;
@property (strong, nonatomic) NSMutableArray <DDPFilter *>*aFilterCollection;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSHashTable *observers;
@property (strong, nonatomic) NSArray <NSString *>*dynamicChangeKeys;
@end

@implementation DDPCacheManager
{
    //已经接收的大小
    NSUInteger _totalAlreadyReceive;
    DDPUser *_currentUser;
    CGSize _videoAspectRatio;
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
        _cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = false;
        _cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = false;
    }
    return _cache;
}

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

- (DDPUser *)currentUser {
    if (_currentUser == nil) {
        _currentUser = [self _currentUser];
    }
    return _currentUser;
}

- (void)setCurrentUser:(DDPUser *)currentUser {
    _currentUser = currentUser;
    [[DDPSharedNetManager sharedNetManager] resetJWTToken:_currentUser.JWTToken];
    [self _saveWithUser:_currentUser];
    
    for (id<DDPCacheManagerDelagate>obj in self.observers) {
        if ([obj respondsToSelector:@selector(userLoginStatusDidChange:)]) {
            [obj userLoginStatusDidChange:_currentUser];
        }
    }
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
- (void)setDanmakuEffectStyle:(JHDanmakuEffectStyle)danmakuEffectStyle {
    [self.cache setObject:@(danmakuEffectStyle) forKey:[self keyWithSEL:_cmd] withBlock:nil];
}

- (JHDanmakuEffectStyle)danmakuEffectStyle {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(JHDanmakuEffectStyleGlow);
        self.danmakuEffectStyle = JHDanmakuEffectStyleGlow;
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

- (void)setLinkInfo:(DDPLinkInfo *)linkInfo {
    _linkInfo = linkInfo;
    
    for (id<DDPCacheManagerDelagate> obs in _observers) {
        if ([obs respondsToSelector:@selector(linkInfoDidChange:)]) {
            [obs linkInfoDidChange:_linkInfo];
        }
    }
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
- (void)setFileSortType:(DDPFileSortType)fileSortType {
    [self.cache setObject:@(fileSortType) forKey:[self keyWithSEL:_cmd]];
}

- (DDPFileSortType)fileSortType {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPFileSortTypeAsc);
        self.fileSortType = DDPFileSortTypeAsc;
    }
    
    return num.integerValue;
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
- (void)setVideoAspectRatio:(CGSize)videoAspectRatio {
    _videoAspectRatio = videoAspectRatio;
    self.mediaPlayer.videoAspectRatio = videoAspectRatio;
}

- (CGSize)videoAspectRatio {
    return _videoAspectRatio;
}

#pragma mark -
- (void)setPlayerSpeed:(float)playerSpeed {
    [self.cache setObject:@(playerSpeed) forKey:[self keyWithSEL:_cmd]];
    self.mediaPlayer.speed = playerSpeed;
}

- (float)playerSpeed {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(1.0f);
        self.playerSpeed = 1.0f;
    }
    
    return num.floatValue;
}

#pragma mark -
- (void)setGuildViewIsShow:(BOOL)guildViewIsShow {
    [[NSUserDefaults standardUserDefaults] setBool:guildViewIsShow forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)guildViewIsShow {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self keyWithSEL:_cmd]];
}

- (void)setLoadLocalDanmaku:(BOOL)loadLocalDanmaku {
    [self.cache setObject:@(loadLocalDanmaku) forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)loadLocalDanmaku {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.loadLocalDanmaku = YES;
    }
    
    return num.boolValue;
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

#pragma mark -

- (NSMutableArray<NSString *> *)refreshTexts {
    if (_refreshTexts == nil) {
        _refreshTexts = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RefreshText" ofType:@"plist"]];
    }
    return _refreshTexts;
}

#pragma mark -
- (void)setIgnoreVersion:(NSString *)ignoreVersion {
    [self.cache setObject:ignoreVersion forKey:[self keyWithSEL:_cmd]];
}

- (NSString *)ignoreVersion {
    NSString *version = (NSString *)[self.cache objectForKey:[self keyWithSEL:_cmd]];
    return version;
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

#pragma mark - 懒加载
- (NSArray<NSString *> *)dynamicChangeKeys {
    if (_dynamicChangeKeys == nil) {
        
        _dynamicChangeKeys = @[DDP_KEYPATH(self, danmakuFont),
                               DDP_KEYPATH(self, danmakuSpeed),
                               DDP_KEYPATH(self, danmakuEffectStyle),
                               DDP_KEYPATH(self, danmakuOpacity),
                               DDP_KEYPATH(self, danmakuLimitCount),
                               DDP_KEYPATH(self, danmakuShieldType),
                               DDP_KEYPATH(self, danmakuOffsetTime),
                               DDP_KEYPATH(self, playerSpeed),
                               DDP_KEYPATH(self, subtitleProtectArea)];
        
        
    }
    return _dynamicChangeKeys;
}

@end
