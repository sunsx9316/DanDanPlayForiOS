//
//  DanmakuDataFormatter.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/1/27.
//  Copyright © 2016年 JimHuang. All rights reserved.
//  把弹幕数组转成字典的工具类
//


@class ParentDanmaku;
@interface DanmakuManager : NSObject

/**
 缓存弹幕

 @param obj 弹幕对象
 @param episodeId 节目id
 @param source 类型
 */
+ (void)saveDanmakuWithObj:(id)obj episodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source;

/**
 获取缓存弹幕

 @param episodeId 节目id
 @param source 类型
 @return 缓存弹幕
 */
+ (NSArray <JHDanmaku *>*)danmakuCacheWithEpisodeId:(NSUInteger)episodeId source:(DanDanPlayDanmakuType)source;
@end
