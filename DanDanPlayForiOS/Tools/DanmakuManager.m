//
//  DanmakuDataFormatter.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/1/27.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DanmakuManager.h"
//#import "DanmakuModel.h"
//#import "NSString+Tools.h"
#import "ScrollDanmaku.h"
#import "FloatDanmaku.h"
//#import "JHDanmakuEngine+Tools.h"
#import <GDataXMLNode.h>

typedef void(^callBackBlock)(JHDanmaku *model);

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

+ (void)saveDanmakuWithObj:(id)obj episodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source {
    NSMutableArray *danmakus = [NSMutableArray array];
    [self switchParseWithSource:source obj:obj block:^(JHDanmaku *model) {
        [danmakus addObject:model];
    }];
    
    YYCache *cache = nil;
    NSString *key = [NSString stringWithFormat:@"%ld", episodeId];
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
    danmakuCollection.collection = danmakus;
    danmakuCollection.saveTime = [NSDate date];
    [cache setObject:danmakuCollection forKey:key withBlock:nil];
}

+ (NSArray <JHDanmaku *>*)danmakuCacheWithEpisodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source {
    
    NSString *key = [NSString stringWithFormat:@"%ld", episodeId];
    NSMutableArray *danmakuCache = [NSMutableArray array];
    NSTimeInterval cacheTime = [CacheManager shareCacheManager].danmakuCacheTime * 24 * 3600;
    
    if (source & DanDanPlayDanmakuTypeBiliBili) {
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].bilibiliDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime ) {
            [[DanmakuManager shareDanmakuManager].bilibiliDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            [danmakuCache addObjectsFromArray:(NSArray *)[[DanmakuManager shareDanmakuManager].bilibiliDanmakuCache objectForKey:key]];
        }
    }
    
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
    
    if (source & DanDanPlayDanmakuTypeOfficial) {
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime ) {
            [[DanmakuManager shareDanmakuManager].officialDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            [danmakuCache addObjectsFromArray:(NSArray *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key]];
        }
    }
    
    //用户发送的弹幕 缓存
    if (source & DanDanPlayDanmakuTypeByUser) {
        [key stringByAppendingString:@"_user"];
        
        JHDanmakuCollection *tempCollection = (JHDanmakuCollection *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key];
        //缓存过期
        if (fabs([tempCollection.saveTime timeIntervalSinceDate:[NSDate date]]) >= cacheTime ) {
            [[DanmakuManager shareDanmakuManager].officialDanmakuCache removeObjectForKey:key withBlock:nil];
        }
        else {
            [danmakuCache addObjectsFromArray:(NSArray *)[[DanmakuManager shareDanmakuManager].officialDanmakuCache objectForKey:key]];
        }
    }
    
    return danmakuCache;
}

//+ (NSMutableDictionary *)dicWithObj:(id)obj source:(DanDanPlayDanmakuSource)source {
//    NSMutableDictionary <NSNumber *,NSMutableArray <ParentDanmaku *> *> *dic = [NSMutableDictionary dictionary];
//    if (obj) {
//        NSFont *font = [UserDefaultManager shareUserDefaultManager].danmakuFont;
//        NSInteger danmakuSpecially = [UserDefaultManager shareUserDefaultManager].danmakuSpecially;
//        
//        [self switchParseWithSource:source obj:obj block:^(DanmakuDataModel *model) {
//            NSInteger time = model.time;
//            if (!dic[@(time)]) dic[@(time)] = [NSMutableArray array];
//            ParentDanmaku *danmaku = [JHDanmakuEngine DanmakuWithText:model.message color:model.color spiritStyle:model.mode shadowStyle:danmakuSpecially fontSize: font.pointSize font:font];
//            danmaku.appearTime = model.time;
//            danmaku.filter = model.isFilter;
//            [dic[@(time)] addObject: danmaku];
//        }];
//    }
//    return dic;
//}
//
//+ (NSMutableArray *)arrWithObj:(id)obj source:(DanDanPlayDanmakuSource)source {
//    NSMutableArray *arr = [NSMutableArray array];
//    if (obj) {
//        NSFont *font = [UserDefaultManager shareUserDefaultManager].danmakuFont;
//        NSInteger danmakufontSpecially = [UserDefaultManager shareUserDefaultManager].danmakuSpecially;
//        
//        [self switchParseWithSource:source obj:obj block:^(DanmakuDataModel *model) {
//            ParentDanmaku *danmaku = [JHDanmakuEngine DanmakuWithText:model.message color:model.color spiritStyle:model.mode shadowStyle:danmakufontSpecially fontSize:font.pointSize font:font];
//            danmaku.appearTime = model.time;
//            danmaku.filter = model.isFilter;
//            [arr addObject: danmaku];
//        }];
//    }
//    return arr;
//}

#pragma mark - 私有方法
+ (void)switchParseWithSource:(DanDanPlayDanmakuType)source obj:(id)obj block:(callBackBlock)block{
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
+ (void)parseAcfunDanmakus:(NSArray *)danmakus block:(callBackBlock)block {
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
+ (void)parseOfficialDanmakus:(NSArray<JHDanmaku *> *)danmakus block:(callBackBlock)block{
    [danmakus enumerateObjectsUsingBlock:^(JHDanmaku * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.filter = [self filterWithDanMudataModel:model];
        if (block) block(model);
    }];
}

//b站解析方式
+ (void)parseBilibiliDamakus:(NSData *)data block:(callBackBlock)block {
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

