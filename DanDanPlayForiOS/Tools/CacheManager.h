//
//  CacheManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHBaseDanmaku.h"


/**
 视频播放模式

 - PlayerPlayModeSingle: 单集播放
 - PlayerPlayModeSingleCircle: 单集循环
 - PlayerPlayModeCircle: 列表循环
 - PlayerPlayModeOrder: 顺序播放
 */
typedef NS_ENUM(NSUInteger, PlayerPlayMode) {
    PlayerPlayModeSingle,
    PlayerPlayModeSingleCircle,
    PlayerPlayModeCircle,
    PlayerPlayModeOrder,
};

@class JHUser;
@interface CacheManager : NSObject


@property (strong, nonatomic) JHUser *user;

//当前分析的视频模型
@property (strong, nonatomic) VideoModel *currentPlayVideoModel;

//列表中的视频
@property (strong, nonatomic) NSMutableArray <VideoModel *>*videoModels;

/**
 弹幕过滤
 */
@property (strong, nonatomic) NSArray <JHFilter *>*danmakuFilters;

/**
 弹幕缓存时间 默认7天
 */
@property (assign, nonatomic) NSUInteger danmakuCacheTime;

/**
 自动请求第三方弹幕
 */
@property (assign, nonatomic) BOOL autoRequestThirdPartyDanmaku;


/**
 是否打开快速匹配
 */
@property (assign, nonatomic) BOOL openFastMatch;


/**
 弹幕字体
 */
@property (strong, nonatomic) UIFont *danmakuFont;

/**
 弹幕边缘特效
 */
@property (assign, nonatomic) JHDanmakuShadowStyle danmakuShadowStyle;

/**
 字幕保护区域
 */
@property (assign, nonatomic) BOOL subtitleProtectArea;

/**
 播放器播放模式
 */
@property (assign, nonatomic) PlayerPlayMode playMode;

/**
 弹幕速度
 */
@property (assign, nonatomic) float danmakuSpeed;

- (void)addDanmakuFilter:(JHFilter *)danmakuFilter;
- (void)removeDanmakuFilter:(JHFilter *)danmakuFilter;


/**
 获取缓存中的关联id
 
 @param model 视频模型
 @return 关联的id
 */
- (NSUInteger)episodeIdWithVideoModel:(VideoModel *)model;

/**
 关联视频和本地节目id

 @param episodeId 节目id
 @param model 视频模型
 */
- (void)saveEpisodeId:(NSUInteger)episodeId videoModel:(VideoModel *)model;

+ (instancetype)shareCacheManager;

@end
