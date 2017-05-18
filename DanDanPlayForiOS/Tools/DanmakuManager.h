//
//  DanmakuDataFormatter.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/1/27.
//  Copyright © 2016年 JimHuang. All rights reserved.
//  把弹幕数组转成字典的工具类
//


@class JHBaseDanmaku;

@interface DanmakuManager : NSObject

/**
 缓存弹幕

 @param obj 弹幕对象
 @param episodeId 节目id
 @param source 类型
 */
+ (JHDanmakuCollection *)saveDanmakuWithObj:(id)obj episodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source;

/**
 获取缓存弹幕

 @param episodeId 节目id
 @param source 类型
 @return 缓存弹幕
 */
+ (NSArray <JHDanmaku *>*)danmakuCacheWithEpisodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source;


/**
 根据视频模型保存弹幕

 @param obj 弹幕
 @param videoModel 视频模型
 @param source 类型
 */
+ (void)saveDanmakuWithObj:(id)obj videoModel:(VideoModel *)videoModel source:(DanDanPlayDanmakuType)source;

/**
 获取缓存弹幕
 
 @param videoModel 视频模型 需要关联过节目才能获取到
 @param source 类型
 @return 缓存弹幕
 */
+ (NSArray <JHDanmaku *>*)danmakuCacheWithVideoModel:(VideoModel *)videoModel source:(DanDanPlayDanmakuType)source;

+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)converDanmakus:(NSArray <JHDanmaku *>*)danmakus;

/**
 转换弹幕模型

 @param danmaku 弹幕模型
 @return 转换后的模型
 */
+ (JHBaseDanmaku *)converDanmaku:(JHDanmaku *)danmaku;


/**
 转换本地弹幕

 @param source 弹幕来源
 @param obj 弹幕对象
 @return 弹幕字典
 */
+ (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)parseLocalDanmakuWithSource:(DanDanPlayDanmakuType)source obj:(id)obj;

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
