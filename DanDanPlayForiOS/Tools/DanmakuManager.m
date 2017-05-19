//
//  DanmakuDataFormatter.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/1/27.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DanmakuManager.h"
#import "JHScrollDanmaku.h"
#import "JHFloatDanmaku.h"
#import <GDataXMLNode.h>

typedef void(^CallBackAction)(JHDanmaku *model);

@interface DanmakuManager ()
@property (strong, nonatomic) YYCache *bilibiliDanmakuCache;
@property (strong, nonatomic) YYCache *acfunDanmakuCache;
@property (strong, nonatomic) YYCache *officialDanmakuCache;
@end

@implementation DanmakuManager

+ (instancetype)shareDanmakuManager {
    static DanmakuManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (JHDanmakuCollection *)saveDanmakuWithObj:(id)obj episodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source {
    if (obj == nil || episodeId == 0) return nil;
    
    //过滤重复弹幕
    NSMutableSet *danmakus = [NSMutableSet set];
    [self switchParseWithSource:source obj:obj block:^(JHDanmaku *model) {
        [danmakus addObject:model];
    }];
    
    YYCache *cache = nil;
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)episodeId];
    if (source & DanDanPlayDanmakuTypeBiliBili) {
        cache = [DanmakuManager shareDanmakuManager].bilibiliDanmakuCache;
    }
    else if (source & DanDanPlayDanmakuTypeAcfun) {
        cache = [DanmakuManager shareDanmakuManager].acfunDanmakuCache;
    }
    else if (source & DanDanPlayDanmakuTypeOfficial) {
        //用户发送的弹幕 缓存
        if (source & DanDanPlayDanmakuTypeByUser) {
            [key stringByAppendingString:@"_user"];
        }
        cache = [DanmakuManager shareDanmakuManager].officialDanmakuCache;
    }
    
    JHDanmakuCollection *danmakuCollection = [[JHDanmakuCollection alloc] init];
    danmakuCollection.collection = [danmakus.allObjects mutableCopy];
    danmakuCollection.saveTime = [NSDate date];
    [cache setObject:danmakuCollection forKey:key withBlock:nil];
    return danmakuCollection;
}

+ (NSArray <JHDanmaku *>*)danmakuCacheWithEpisodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source {
    
    if (episodeId == 0) return @[];
    
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)episodeId];
    //过滤重复弹幕
    NSMutableSet *danmakuCache = [NSMutableSet set];
    NSTimeInterval cacheTime = [CacheManager shareCacheManager].danmakuCacheTime * 24 * 3600;
    
    //获取的是B站弹幕
    if (source & DanDanPlayDanmakuTypeBiliBili) {
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].bilibiliDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime) {
            [[DanmakuManager shareDanmakuManager].bilibiliDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            [danmakuCache addObjectsFromArray:(NSArray *)[[DanmakuManager shareDanmakuManager].bilibiliDanmakuCache objectForKey:key]];
        }
    }
    
    //获取的是A站弹幕
    if (source & DanDanPlayDanmakuTypeAcfun) {
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].acfunDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime ) {
            [[DanmakuManager shareDanmakuManager].acfunDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            [danmakuCache addObjectsFromArray:(NSArray *)[[DanmakuManager shareDanmakuManager].acfunDanmakuCache objectForKey:key]];
        }
    }
    
    //获取的是官方弹幕
    if (source & DanDanPlayDanmakuTypeOfficial) {
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime ) {
            [[DanmakuManager shareDanmakuManager].officialDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            JHDanmakuCollection *cacheCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
            [danmakuCache addObjectsFromArray:cacheCollection.collection];
        }
    }
    
    //用户发送的弹幕 缓存
    if (source & DanDanPlayDanmakuTypeByUser) {
        [key stringByAppendingString:@"_user"];
        
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime) {
            [[DanmakuManager shareDanmakuManager].officialDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            [danmakuCache addObjectsFromArray:(NSArray *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key]];
        }
    }
    
    return danmakuCache.allObjects;
}

+ (void)saveDanmakuWithObj:(id)obj videoModel:(VideoModel *)videoModel source:(DanDanPlayDanmakuType)source {
    NSDictionary *dic = [[CacheManager shareCacheManager] episodeInfoWithVideoModel:videoModel];
    NSUInteger episodeId = [dic[videoEpisodeIdKey] integerValue];
    if (episodeId == 0) return;
    
    [self saveDanmakuWithObj:obj episodeId:episodeId source:source];
}

+ (NSArray <JHDanmaku *>*)danmakuCacheWithVideoModel:(VideoModel *)videoModel source:(DanDanPlayDanmakuType)source {
    NSDictionary *dic = [[CacheManager shareCacheManager] episodeInfoWithVideoModel:videoModel];
    NSUInteger episodeId = [dic[videoEpisodeIdKey] integerValue];
    if (episodeId == 0) return @[];
    
    return [self danmakuCacheWithEpisodeId:episodeId source:source];
}

+ (NSMutableDictionary <NSNumber *, NSMutableArray<JHBaseDanmaku *>*>*)converDanmakus:(NSArray <JHDanmaku *>*)danmakus {
    NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *> *> *dic = [NSMutableDictionary dictionary];
    UIFont *font = [CacheManager shareCacheManager].danmakuFont;
    JHDanmakuShadowStyle shadowStyle = [CacheManager shareCacheManager].danmakuShadowStyle;

    [danmakus enumerateObjectsUsingBlock:^(JHDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger time = obj.time;
        NSMutableArray *danmakus = dic[@(time)];
        if (danmakus == nil) {
            danmakus = [NSMutableArray array];
            dic[@(time)] = danmakus;
        }
        
        JHBaseDanmaku *tempDanmaku = nil;
        if (obj.mode == 4 || obj.mode == 5) {
            tempDanmaku = [[JHFloatDanmaku alloc] initWithFontSize:0 textColor:[UIColor colorWithRGB:obj.color] text:obj.message shadowStyle:shadowStyle font:font during:3 direction:obj.mode == 4 ? JHFloatDanmakuDirectionB2T : JHFloatDanmakuDirectionT2B];
        }
        else {
            CGFloat speed = 130 - obj.message.length * 2.5;
            
            if (speed < 50) {
                speed = 50;
            }
            
            speed += arc4random() % 20;
            
            //arc4random() % 100 + 50
            
            tempDanmaku = [[JHScrollDanmaku alloc] initWithFontSize:0 textColor:[UIColor colorWithRGB:obj.color] text:obj.message shadowStyle:shadowStyle font:font speed:speed direction:JHScrollDanmakuDirectionR2L];
        }
        tempDanmaku.appearTime = obj.time;
        
        [danmakus addObject:tempDanmaku];
    }];

    return dic;
}

+ (JHBaseDanmaku *)converDanmaku:(JHDanmaku *)danmaku {
    if (danmaku == nil) return nil;
    
    return [self converDanmakus:@[danmaku]].allValues.firstObject.firstObject;
}

+ (CGFloat)danmakuCacheSize {
    DanmakuManager *manager = [DanmakuManager shareDanmakuManager];
    CGFloat size = [manager.bilibiliDanmakuCache.diskCache totalCost];
    size += [manager.acfunDanmakuCache.diskCache totalCost];
    size += [manager.officialDanmakuCache.diskCache totalCost];
    return size;
}

+ (void)removeAllDanmakuCache {
    DanmakuManager *manager = [DanmakuManager shareDanmakuManager];
    [manager.bilibiliDanmakuCache.diskCache removeAllObjects];
    [manager.acfunDanmakuCache.diskCache removeAllObjects];
    [manager.officialDanmakuCache.diskCache removeAllObjects];
}

+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)parseLocalDanmakuWithSource:(DanDanPlayDanmakuType)source obj:(id)obj {
    NSMutableArray *danmakus = [NSMutableArray array];
    [self switchParseWithSource:source obj:obj block:^(JHDanmaku *model) {
        [danmakus addObject:model];
    }];
    
    return [self converDanmakus:danmakus];
}


#pragma mark - 私有方法
+ (void)switchParseWithSource:(DanDanPlayDanmakuType)source obj:(id)obj block:(CallBackAction)block {
    if (source & DanDanPlayDanmakuTypeBiliBili || source & DanDanPlayDanmakuTypeByUser) {
        [self parseBilibiliDamakus:obj block:block];
    }
    else if (source & DanDanPlayDanmakuTypeAcfun) {
        [self parseAcfunDanmakus:obj block:block];
    }
    else if (source & DanDanPlayDanmakuTypeOfficial) {
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
            
            JHDanmaku *model = [[JHDanmaku alloc] init];
            model.time = [tempArr[0] floatValue];
            model.color = [tempArr[1] intValue];
            model.mode = [tempArr[2] intValue];
            model.message = dic[@"m"];
            model.filter = [self filterWithDanMudataModel:model];
            if (block) block(model);
        }
    }
}

//官方解析方式
+ (void)parseOfficialDanmakus:(JHDanmakuCollection *)danmakus block:(CallBackAction)block{
    [danmakus.collection enumerateObjectsUsingBlock:^(JHDanmaku * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.filter = [self filterWithDanMudataModel:model];
        if (block) block(model);
    }];
}

//b站解析方式
+ (void)parseBilibiliDamakus:(NSData *)data block:(CallBackAction)block {
    GDataXMLDocument *document=[[GDataXMLDocument alloc] initWithData:data error:nil];
    GDataXMLElement *rootElement = document.rootElement;
    NSArray *array = [rootElement elementsForName:@"d"];
    for (GDataXMLElement *ele in array) {
            NSArray* strArr = [[[ele attributeForName:@"p"] stringValue] componentsSeparatedByString:@","];
            JHDanmaku* model = [[JHDanmaku alloc] init];
            model.time = [strArr[0] floatValue];
            model.mode = [strArr[1] intValue];
            model.color = [strArr[3] intValue];
            model.message = [ele stringValue];
            model.filter = [self filterWithDanMudataModel:model];
            if (block) block(model);
    }
}


//过滤弹幕
+ (BOOL)filterWithDanMudataModel:(JHDanmaku *)model {
    NSArray <JHFilter *>*danmakuFilters = [CacheManager shareCacheManager].danmakuFilters;
    for (JHFilter *filter in danmakuFilters) {
        //使用正则表达式
        if (filter.isRegex) {
            if ([model.message matchesRegex:filter.content options:NSRegularExpressionCaseInsensitive]) {
                return YES;
            }
        }
        else if ([model.message containsString:filter.content]){
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

