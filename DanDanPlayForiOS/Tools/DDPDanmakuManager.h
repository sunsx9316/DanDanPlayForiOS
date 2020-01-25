//
//  DanmakuDataFormatter.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/1/27.
//  Copyright © 2016年 JimHuang. All rights reserved.
//  把弹幕数组转成字典的工具类
//


@class JHBaseDanmaku;

@interface DDPDanmakuManager : NSObject

/**
 缓存弹幕

 @param obj 弹幕对象
 @param episodeId 节目id
 @param source 类型
 */
+ (DDPDanmakuCollection *)saveDanmakuWithObj:(id)obj episodeId:(NSUInteger)episodeId source:(DDPDanmakuType)source;

/**
 根据视频模型保存弹幕

 @param obj 弹幕
 @param videoModel 视频模型
 @param source 类型
 */
+ (void)saveDanmakuWithObj:(id)obj videoModel:(DDPVideoModel *)videoModel source:(DDPDanmakuType)source;

/**
 根据节目id获取缓存弹幕
 
 @param episodeId 节目id
 @param source 类型
 @return 缓存弹幕
 */
+ (NSArray <DDPDanmaku *>*)danmakuCacheWithEpisodeId:(NSUInteger)episodeId source:(DDPDanmakuType)source;

/**
 根据视频模型获取缓存弹幕
 
 @param videoModel 视频模型 需要关联过节目才能获取到
 @param source 类型
 @return 缓存弹幕
 */
+ (NSArray <DDPDanmaku *>*)danmakuCacheWithVideoModel:(DDPVideoModel *)videoModel source:(DDPDanmakuType)source;

/**
 转换弹幕

 @param danmakus 弹幕数组
 @param filter 是否过滤弹幕
 @return 时间字典形式
 */
+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)converDanmakus:(NSArray <DDPDanmaku *>*)danmakus filter:(BOOL)filter;

/**
 转换弹幕模型

 @param danmaku 弹幕模型
 @return 转换后的模型
 */
+ (JHBaseDanmaku *)converDanmaku:(DDPDanmaku *)danmaku;


/**
 转换本地弹幕

 @param source 弹幕来源
 @param obj 弹幕对象
 @return 弹幕字典
 */
+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)parseLocalDanmakuWithSource:(DDPDanmakuType)source obj:(id)obj;

/// 转换弹幕为数组
/// @param source 弹幕来源
/// @param obj 弹幕对象
+ (NSArray <DDPDanmaku *>*)parseLocalDanmakuToArrayWithSource:(DDPDanmakuType)source obj:(id)obj;

+ (BOOL)filterWithDanmakuContent:(NSString *)content danmakuFilters:(NSArray <DDPFilter *>*)danmakuFilters;

/**
 弹幕缓存大小

 @return 弹幕缓存大小
 */
+ (CGFloat)danmakuCacheSize;

/**
 移除弹幕缓存时间
 */
+ (void)removeAllDanmakuCache;


@end
