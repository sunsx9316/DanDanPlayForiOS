//
//  DanmakuDataFormatter.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/1/27.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPDanmakuManager.h"
#import "JHScrollDanmaku.h"
#import "JHFloatDanmaku.h"
#import "DDPBaseDanmaku+Tools.h"
#import "DDPCacheManager+multiply.h"
#import "DDPVideoModel+Tools.h"

typedef void(^CallBackAction)(DDPDanmaku *model);

@interface DDPDanmakuManager ()
@property (strong, nonatomic) YYCache *bilibiliDanmakuCache;
@property (strong, nonatomic) YYCache *acfunDanmakuCache;
@property (strong, nonatomic) YYCache *officialDanmakuCache;
@end

@implementation DDPDanmakuManager

+ (instancetype)shareDanmakuManager {
    static DDPDanmakuManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (DDPDanmakuCollection *)saveDanmakuWithObj:(id)obj episodeId:(NSUInteger)episodeId source:(DDPDanmakuType)source {
    if (obj == nil || episodeId == 0) return nil;
    
    //过滤重复弹幕
    NSMutableSet *danmakus = [NSMutableSet set];
    [self switchParseWithSource:source obj:obj block:^(DDPDanmaku *model) {
        [danmakus addObject:model];
    }];
    
    YYCache *cache = nil;
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)episodeId];
    if (source & DDPDanmakuTypeBiliBili) {
        cache = [DDPDanmakuManager shareDanmakuManager].bilibiliDanmakuCache;
    }
    else if (source & DDPDanmakuTypeAcfun) {
        cache = [DDPDanmakuManager shareDanmakuManager].acfunDanmakuCache;
    }
    else if (source & DDPDanmakuTypeOfficial) {
        cache = [DDPDanmakuManager shareDanmakuManager].officialDanmakuCache;
    }
    //用户发送的弹幕 缓存
    else if (source & DDPDanmakuTypeByUser) {
        key = [key stringByAppendingString:@"_user"];
        cache = [DDPDanmakuManager shareDanmakuManager].officialDanmakuCache;
    }
    
    DDPDanmakuCollection *danmakuCollection = [[DDPDanmakuCollection alloc] init];
    danmakuCollection.collection = [danmakus.allObjects mutableCopy];
    danmakuCollection.saveTime = [NSDate date];
    danmakuCollection.identity = episodeId;
    [cache setObject:danmakuCollection forKey:key withBlock:nil];
    return danmakuCollection;
}

+ (void)saveDanmakuWithObj:(id)obj videoModel:(DDPVideoModel *)videoModel source:(DDPDanmakuType)source {
    NSUInteger episodeId = videoModel.relevanceEpisodeId;
    if (episodeId == 0) return;
    
    [self saveDanmakuWithObj:obj episodeId:episodeId source:source];
}

+ (NSArray <DDPDanmaku *>*)danmakuCacheWithEpisodeId:(NSUInteger)episodeId source:(DDPDanmakuType)source {
    
    if (episodeId == 0) return @[];
    
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)episodeId];
    //过滤重复弹幕
    NSMutableSet *danmakuCache = [NSMutableSet set];
    NSUInteger danmakuCacheTime = [DDPCacheManager shareCacheManager].danmakuCacheTime;
    NSTimeInterval cacheTime = 0;
    if (danmakuCacheTime >= CACHE_ALL_DANMAKU_FLAG) {
        cacheTime = CGFLOAT_MAX;
    }
    else {
        cacheTime = [DDPCacheManager shareCacheManager].danmakuCacheTime * 24 * 3600;
    }
    
    //获取的是B站弹幕
    if (source & DDPDanmakuTypeBiliBili) {
        DDPDanmakuCollection *tempCollection = (DDPDanmakuCollection *)[[DDPDanmakuManager shareDanmakuManager].bilibiliDanmakuCache objectForKey:key];
        if ([tempCollection isKindOfClass:[DDPDanmakuCollection class]]) {
            //缓存过期
            if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime) {
                [[DDPDanmakuManager shareDanmakuManager].bilibiliDanmakuCache removeObjectForKey:key withBlock:nil];
            }
            else {
                [danmakuCache addObjectsFromArray:tempCollection.collection];
            }
        }
    }
    
    //获取的是A站弹幕
    if (source & DDPDanmakuTypeAcfun) {
        DDPDanmakuCollection *tempCollection = (DDPDanmakuCollection *)[[DDPDanmakuManager shareDanmakuManager].acfunDanmakuCache objectForKey:key];
        if ([tempCollection isKindOfClass:[DDPDanmakuCollection class]]) {
            //缓存过期
            if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime) {
                [[DDPDanmakuManager shareDanmakuManager].acfunDanmakuCache removeObjectForKey:key withBlock:nil];
            }
            else {
                [danmakuCache addObjectsFromArray:tempCollection.collection];
            }
        }
    }
    
    //获取的是官方弹幕
    if (source & DDPDanmakuTypeOfficial) {
        DDPDanmakuCollection *tempCollection = (DDPDanmakuCollection *)[[DDPDanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
        if ([tempCollection isKindOfClass:[DDPDanmakuCollection class]]) {
            //缓存过期
            if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime) {
                [[DDPDanmakuManager shareDanmakuManager].officialDanmakuCache removeObjectForKey:key withBlock:nil];
            }
            else {
                [danmakuCache addObjectsFromArray:tempCollection.collection];
            }
        }
    }
    
    //用户发送的弹幕 缓存
    if (source & DDPDanmakuTypeByUser) {
        key = [key stringByAppendingString:@"_user"];
        
        DDPDanmakuCollection *tempCollection = (DDPDanmakuCollection *)[[DDPDanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
        if ([tempCollection isKindOfClass:[DDPDanmakuCollection class]]) {
            //缓存过期
            if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime) {
                [[DDPDanmakuManager shareDanmakuManager].officialDanmakuCache removeObjectForKey:key withBlock:nil];
            }
            else {
                [danmakuCache addObjectsFromArray:tempCollection.collection];
            }
        }
    }
    
    return danmakuCache.allObjects;
}


+ (NSArray <DDPDanmaku *>*)danmakuCacheWithVideoModel:(DDPVideoModel *)videoModel source:(DDPDanmakuType)source {
    NSUInteger episodeId = videoModel.relevanceEpisodeId;
    if (episodeId == 0) return @[];
    
    return [self danmakuCacheWithEpisodeId:episodeId source:source];
}

+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)converDanmakus:(NSArray <DDPDanmaku *>*)danmakus filter:(BOOL)filter {
    NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *> *> *dic = [NSMutableDictionary dictionary];
    UIFont *font = [DDPCacheManager shareCacheManager].danmakuFont;
    JHDanmakuEffectStyle shadowStyle = [DDPCacheManager shareCacheManager].danmakuEffectStyle;
    NSArray *danmakuFilters = [DDPCacheManager shareCacheManager].danmakuFilters;
    
    [danmakus enumerateObjectsUsingBlock:^(DDPDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger time = obj.time;
        NSMutableArray *danmakus = dic[@(time)];
        if (danmakus == nil) {
            danmakus = [NSMutableArray array];
            dic[@(time)] = danmakus;
        }
        
        JHBaseDanmaku *tempDanmaku = nil;
        if (obj.mode == DDPDanmakuModeBottom || obj.mode == DDPDanmakuModeTop) {
            tempDanmaku = [[JHFloatDanmaku alloc] initWithFont:font text:obj.message textColor:[UIColor colorWithRGB:obj.color] effectStyle:shadowStyle during:3 position:obj.mode == DDPDanmakuModeBottom ? JHFloatDanmakuPositionAtBottom : JHFloatDanmakuPositionAtTop];
        }
        else {
            tempDanmaku = [[JHScrollDanmaku alloc] initWithFont:font text:obj.message textColor:[UIColor colorWithRGB:obj.color] effectStyle:shadowStyle direction:JHScrollDanmakuDirectionR2L];
        }
        tempDanmaku.appearTime = obj.time;
        if (filter) {
            tempDanmaku.filter = [self filterWithDanmakuContent:obj.message danmakuFilters:danmakuFilters];
        }
        
        [danmakus addObject:tempDanmaku];
    }];

    return dic;
}

+ (JHBaseDanmaku *)converDanmaku:(DDPDanmaku *)danmaku {
    if (danmaku == nil) return nil;
    
    return [self converDanmakus:@[danmaku] filter:NO].allValues.firstObject.firstObject;
}

+ (CGFloat)danmakuCacheSize {
    DDPDanmakuManager *manager = [DDPDanmakuManager shareDanmakuManager];
    CGFloat size = [manager.bilibiliDanmakuCache.diskCache totalCost];
    size += [manager.acfunDanmakuCache.diskCache totalCost];
    size += [manager.officialDanmakuCache.diskCache totalCost];
    return size;
}

+ (void)removeAllDanmakuCache {
    DDPDanmakuManager *manager = [DDPDanmakuManager shareDanmakuManager];
    [manager.bilibiliDanmakuCache.memoryCache removeAllObjects];
    [manager.bilibiliDanmakuCache.diskCache removeAllObjects];
    [manager.acfunDanmakuCache.memoryCache removeAllObjects];
    [manager.acfunDanmakuCache.diskCache removeAllObjects];
    [manager.officialDanmakuCache.memoryCache removeAllObjects];
    [manager.officialDanmakuCache.diskCache removeAllObjects];
}

+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)parseLocalDanmakuWithSource:(DDPDanmakuType)source obj:(id)obj {
    let danmakus = [self parseLocalDanmakuToArrayWithSource:source obj:obj];
    return [self converDanmakus:danmakus filter:NO];
}

+ (NSArray <DDPDanmaku *>*)parseLocalDanmakuToArrayWithSource:(DDPDanmakuType)source obj:(id)obj {
    NSMutableArray <DDPDanmaku *>*danmakus = [NSMutableArray array];
    [self switchParseWithSource:source obj:obj block:^(DDPDanmaku *model) {
        [danmakus addObject:model];
    }];
    
    return danmakus;
}

#pragma mark - 私有方法
+ (void)switchParseWithSource:(DDPDanmakuType)source obj:(id)obj block:(CallBackAction)block {
    if (source & DDPDanmakuTypeBiliBili) {
        [self parseBilibiliDamakus:obj block:block];
    }
    else if (source & DDPDanmakuTypeByUser) {
        [self parseUserSendDamakus:obj block:block];
    }
    else if (source & DDPDanmakuTypeAcfun) {
        [self parseAcfunDanmakus:obj block:block];
    }
    else if (source & DDPDanmakuTypeOfficial) {
        [self parseOfficialDanmakus:obj block:block];
    }
}

//a站解析方式
+ (void)parseAcfunDanmakus:(NSArray *)danmakus block:(CallBackAction)block {
    for (NSArray *arr2 in danmakus) {
        for (NSDictionary *dic in arr2) {
            NSString *str = dic[@"c"];
            NSArray *tempArr = [str componentsSeparatedByString:@","];
            if (tempArr.count == 0) continue;
            
            DDPDanmaku *model = [[DDPDanmaku alloc] init];
            model.time = [tempArr[0] floatValue];
            model.color = [tempArr[1] intValue];
            model.mode = [tempArr[2] intValue];
            model.message = dic[@"m"];
            if (block) block(model);
        }
    }
}

//官方解析方式
+ (void)parseOfficialDanmakus:(DDPDanmakuCollection *)danmakus block:(CallBackAction)block{
    [danmakus.collection enumerateObjectsUsingBlock:^(DDPDanmaku * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block) block(model);
    }];
}

//b站解析方式
+ (void)parseBilibiliDamakus:(NSData *)data block:(CallBackAction)block {
    NSDictionary *dic = [NSDictionary dictionaryWithXML:data];
    NSArray *array = dic[@"d"];
    for (NSDictionary *dic in array) {
        NSArray *strArr = [dic[@"p"] componentsSeparatedByString:@","];
        DDPDanmaku* model = [[DDPDanmaku alloc] init];
        if (strArr.count >= 4) {
            model.time = [strArr[0] floatValue];
            model.mode = [strArr[1] intValue];
            model.color = [strArr[3] intValue];
        }
        model.message = dic[@"_text"];
        if (block) block(model);
    }
}

+ (void)parseUserSendDamakus:(NSArray <DDPDanmaku *>*)danmakus block:(CallBackAction)block {
    [danmakus enumerateObjectsUsingBlock:^(DDPDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block) {
            block(obj);
        }
    }];
}


//过滤弹幕
+ (BOOL)filterWithDanmakuContent:(NSString *)content danmakuFilters:(NSArray <DDPFilter *>*)danmakuFilters {
    for (DDPFilter *filter in danmakuFilters) {
        
        if (filter.enable == false) {
            continue;
        }
        
        //使用正则表达式
        if (filter.isRegex && filter.content.length > 0) {
            if ([content matchesRegex:filter.content options:NSRegularExpressionCaseInsensitive]) {
                return YES;
            }
        }
        else if ([content containsString:filter.content]){
            return YES;
        }
    }
    return NO;
}


#pragma mark - 懒加载
- (YYCache *)bilibiliDanmakuCache {
    if (_bilibiliDanmakuCache == nil) {
        _bilibiliDanmakuCache = [[YYCache alloc] initWithName:@"danmaku_cache/bilibili_danmaku_cache"];
    }
    return _bilibiliDanmakuCache;
}

- (YYCache *)acfunDanmakuCache {
    if (_acfunDanmakuCache == nil) {
        _acfunDanmakuCache = [[YYCache alloc] initWithName:@"danmaku_cache/acfun_danmaku_cache"];
    }
    return _acfunDanmakuCache;
}

- (YYCache *)officialDanmakuCache {
    if (_officialDanmakuCache == nil) {
        _officialDanmakuCache = [[YYCache alloc] initWithName:@"danmaku_cache/official_danmaku_cache"];
    }
    return _officialDanmakuCache;
}

@end

