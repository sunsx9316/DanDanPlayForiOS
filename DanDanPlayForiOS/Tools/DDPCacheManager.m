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
static NSString *const collectionCacheKey = @"collection_cache";


@interface DDPCacheManager ()<TOSMBSessionDownloadTaskDelegate>
//@property (strong, nonatomic) YYCache *cache;

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
//- (YYCache *)cache {
//    if (_cache == nil) {
//        _cache = [[YYCache alloc] initWithName:@"dandanplay_cache"];
//        _cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = false;
//        _cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = false;
//    }
//    return _cache;
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = danmakuFont.fontName;
    dic[@"size"] = @(danmakuFont.pointSize);
    dic[@"isSystemFont"] = @(danmakuFont.isSystemFont);
    [NSUserDefaults.standardUserDefaults setObject:dic forKey:[self keyWithSEL:_cmd]];
}

- (UIFont *)danmakuFont {
    NSDictionary *fontDic = [NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    UIFont *font = nil;
    if ([fontDic isKindOfClass:[NSDictionary class]]) {
        NSString *name = fontDic[@"name"];
        NSNumber *size = fontDic[@"size"];
        NSNumber *isSystemFont = fontDic[@"isSystemFont"];
        
        if (isSystemFont.boolValue) {
            UIFont *font = [UIFont systemFontOfSize:size.doubleValue];
            font.isSystemFont = YES;
            return font;
        }
        
        font = [UIFont fontWithName:name size:size.doubleValue];
        font.isSystemFont = isSystemFont.boolValue;
        
        if (!font) {
            font = [UIFont systemFontOfSize:size.doubleValue];
            font.isSystemFont = YES;
            self.danmakuFont = font;
        }
    } else {
        font = [UIFont ddp_normalSizeFont];
        font.isSystemFont = YES;
        self.danmakuFont = font;
    }
    
    return font;
}

#pragma mark - 
- (void)setDanmakuEffectStyle:(JHDanmakuEffectStyle)danmakuEffectStyle {
    [NSUserDefaults.standardUserDefaults setInteger:danmakuEffectStyle forKey:[self keyWithSEL:_cmd]];
}

- (JHDanmakuEffectStyle)danmakuEffectStyle {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(JHDanmakuEffectStyleGlow);
        self.danmakuEffectStyle = JHDanmakuEffectStyleGlow;
    }
    return [num integerValue];
}

#pragma mark - 
- (void)setSubtitleProtectArea:(BOOL)subtitleProtectArea {
    [NSUserDefaults.standardUserDefaults setBool:subtitleProtectArea forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)subtitleProtectArea {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.subtitleProtectArea = YES;
    }
    return [num boolValue];
}

#pragma mark -
- (void)setDanmakuCacheTime:(NSUInteger)danmakuCacheTime {
    [NSUserDefaults.standardUserDefaults setInteger:danmakuCacheTime forKey:[self keyWithSEL:_cmd]];
}

- (NSUInteger)danmakuCacheTime {
    NSNumber *time = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (time == nil) {
        time = @(7);
        self.danmakuCacheTime = 7;
    }
    
    return [time unsignedIntegerValue];
}

#pragma mark -
- (void)setAutoRequestThirdPartyDanmaku:(BOOL)autoRequestThirdPartyDanmaku {
    [NSUserDefaults.standardUserDefaults setBool:autoRequestThirdPartyDanmaku forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)autoRequestThirdPartyDanmaku {
    NSNumber *autoRequestThirdPartyDanmaku = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (autoRequestThirdPartyDanmaku == nil) {
        autoRequestThirdPartyDanmaku = @(YES);
        self.autoRequestThirdPartyDanmaku = YES;
    }
    
    return [autoRequestThirdPartyDanmaku boolValue];
}

#pragma mark -
- (void)setOpenFastMatch:(BOOL)openFastMatch {
    [NSUserDefaults.standardUserDefaults setBool:openFastMatch forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)openFastMatch {
    NSNumber * num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.openFastMatch = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setOpenAutoDownloadSubtitle:(BOOL)openAutoDownloadSubtitle {
    [NSUserDefaults.standardUserDefaults setBool:openAutoDownloadSubtitle forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)openAutoDownloadSubtitle {
    NSNumber * num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.openAutoDownloadSubtitle = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setUseTouchIdLogin:(BOOL)useTouchIdLogin {
    [NSUserDefaults.standardUserDefaults setBool:useTouchIdLogin forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)useTouchIdLogin {
    NSNumber * num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.useTouchIdLogin = YES;
    }
    return num.boolValue;
}

#pragma mark -
- (void)setPriorityLoadLocalDanmaku:(BOOL)priorityLoadLocalDanmaku {
    [NSUserDefaults.standardUserDefaults setBool:priorityLoadLocalDanmaku forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)priorityLoadLocalDanmaku {
    NSNumber * num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
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
    [NSUserDefaults.standardUserDefaults setInteger:playMode forKey:[self keyWithSEL:_cmd]];
}

- (DDPPlayerPlayMode)playMode {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPPlayerPlayModeOrder);
        self.playMode = DDPPlayerPlayModeOrder;
    }
    
    return num.integerValue;
}

#pragma mark - 
- (float)danmakuSpeed {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @1;
        self.danmakuSpeed = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuSpeed:(float)danmakuSpeed {
    [NSUserDefaults.standardUserDefaults setFloat:danmakuSpeed forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (float)danmakuOpacity {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @1;
        self.danmakuOpacity = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuOpacity:(float)danmakuOpacity {
    [NSUserDefaults.standardUserDefaults setFloat:danmakuOpacity forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (void)setFileSortType:(DDPFileSortType)fileSortType {
    [NSUserDefaults.standardUserDefaults setInteger:fileSortType forKey:[self keyWithSEL:_cmd]];
}

- (DDPFileSortType)fileSortType {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPFileSortTypeAsc);
        self.fileSortType = DDPFileSortTypeAsc;
    }
    
    return num.integerValue;
}

#pragma mark -
- (UIColor *)sendDanmakuColor {
    NSData *colorData = (NSData *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    UIColor *color = nil;
    if (![colorData isKindOfClass:[NSData class]]) {
        color = [UIColor whiteColor];
        self.sendDanmakuColor = color;
    } else {
        color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    return color;
}

- (void)setSendDanmakuColor:(UIColor *)sendDanmakuColor {
    [NSUserDefaults.standardUserDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:sendDanmakuColor] forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (DDPDanmakuMode)sendDanmakuMode {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPDanmakuModeNormal);
        self.sendDanmakuMode = DDPDanmakuModeNormal;
    }
    
    return num.integerValue;
}

- (void)setSendDanmakuMode:(DDPDanmakuMode)sendDanmakuMode {
    [NSUserDefaults.standardUserDefaults setObject:@(sendDanmakuMode) forKey:[self keyWithSEL:_cmd]];
}

#pragma mark -
- (NSUInteger)danmakuLimitCount {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(14);
        self.danmakuLimitCount = 14;
    }
    
    return num.integerValue;
}

- (void)setDanmakuLimitCount:(NSUInteger)danmakuLimitCount {
    [NSUserDefaults.standardUserDefaults setObject:@(danmakuLimitCount) forKey:[self keyWithSEL:_cmd]];
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
    [NSUserDefaults.standardUserDefaults setObject:@(playerSpeed) forKey:[self keyWithSEL:_cmd]];
    self.mediaPlayer.speed = playerSpeed;
}

- (float)playerSpeed {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
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
    [NSUserDefaults.standardUserDefaults setObject:@(loadLocalDanmaku) forKey:[self keyWithSEL:_cmd]];
}

- (BOOL)loadLocalDanmaku {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(YES);
        self.loadLocalDanmaku = YES;
    }
    
    return num.boolValue;
}


#pragma mark -
- (void)setPlayInterfaceOrientation:(UIInterfaceOrientation)playInterfaceOrientation {
    [NSUserDefaults.standardUserDefaults setObject:@(playInterfaceOrientation) forKey:[self keyWithSEL:_cmd]];
}

- (UIInterfaceOrientation)playInterfaceOrientation {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(UIInterfaceOrientationLandscapeRight);
        self.playInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
    }
    
    return num.integerValue;
}

- (DDPDanmakuShieldType)danmakuShieldType {
    NSNumber *num = (NSNumber *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    if (num == nil) {
        num = @(DDPDanmakuShieldTypeNone);
        self.danmakuShieldType = DDPDanmakuShieldTypeNone;
    }
    
    return num.integerValue;
}

- (void)setDanmakuShieldType:(DDPDanmakuShieldType)danmakuShieldType {
    [NSUserDefaults.standardUserDefaults setObject:@(danmakuShieldType) forKey:[self keyWithSEL:_cmd]];
}

- (void)setUserDefineRequestDomain:(NSString *)userDefineRequestDomain {
    [NSUserDefaults.standardUserDefaults setObject:userDefineRequestDomain forKey:[self keyWithSEL:_cmd]];
}

- (NSString *)userDefineRequestDomain {
    NSString *path = (NSString *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    return path;
}

- (void)setUserDefineResRequestDomain:(NSString *)userDefineResRequestDomain {
    [NSUserDefaults.standardUserDefaults setObject:userDefineResRequestDomain forKey:[self keyWithSEL:_cmd]];
}

- (NSString *)userDefineResRequestDomain {
    NSString *path = (NSString *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    return path;
}

#pragma mark -
- (NSMutableDictionary *)folderCache {
    NSMutableDictionary <NSString *, NSArray <NSString *>*>*dic = (NSMutableDictionary *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    
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
    [NSUserDefaults.standardUserDefaults setObject:folderCache forKey:[self keyWithSEL:_cmd]];
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
    [NSUserDefaults.standardUserDefaults setObject:ignoreVersion forKey:[self keyWithSEL:_cmd]];
}

- (NSString *)ignoreVersion {
    NSString *version = (NSString *)[NSUserDefaults.standardUserDefaults objectForKey:[self keyWithSEL:_cmd]];
    return version;
}

- (void)setSubtitleDelay:(CGFloat)subtitleDelay {
    self.mediaPlayer.subtitleDelay = subtitleDelay;
}

- (CGFloat)subtitleDelay {
    return self.mediaPlayer.subtitleDelay;
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
