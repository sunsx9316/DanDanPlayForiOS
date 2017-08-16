//
//  JHDanmakuEngine.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHBaseDanmaku.h"
#import "JHDanmakuCanvas.h"

@class JHDanmakuEngine;
@protocol JHDanmakuEngineDelegate <NSObject>
@optional

/**
 在指定时间发射弹幕

 @param danmakuEngine 弹幕引擎
 @param time 时间
 @return 发射的弹幕
 */
- (NSArray <__kindof JHBaseDanmaku*>*)danmakuEngine:(JHDanmakuEngine *)danmakuEngine didSendDanmakuAtTime:(NSUInteger)time;

/**
 是否发射某个弹幕

 @param danmakuEngine 弹幕引擎
 @param danmaku 弹幕
 @return 是否发射
 */
- (BOOL)danmakuEngine:(JHDanmakuEngine *)danmakuEngine shouldSendDanmaku:(__kindof JHBaseDanmaku *)danmaku;

- (NSTimeInterval)engineTimeSystemFollowWithOuterTimeSystem;

@end

@interface JHDanmakuEngine : NSObject

@property (weak, nonatomic) id<JHDanmakuEngineDelegate> delegate;

/**
 计时器多少秒调用一次代理方法 默认1s
 */
@property (assign, nonatomic) NSUInteger timeInterval;

/**
 弹幕画布
 */
@property (strong, nonatomic) JHDanmakuCanvas *canvas;

/**
 把窗口平分为多少份 默认0 自动调整
 */
@property (assign, nonatomic) NSInteger channelCount;

/**
 当前时间
 */
@property (assign, nonatomic) NSTimeInterval currentTime;

/**
 偏移时间 让弹幕偏移一般设置这个就行
 */
@property (assign, nonatomic) NSTimeInterval offsetTime;

/**
 全局文字风格字典 默认不使用 会覆盖个体设置
 */
@property (strong, nonatomic) NSDictionary *globalAttributedDic;

/**
 全局字体 默认不使用 会覆盖个体设置 方便更改字体大小
 */
@property (strong, nonatomic) JHFont *globalFont;

/**
 全局字体边缘特效 默认不使用 会覆盖个体设置
 */
@property (assign, nonatomic) JHDanmakuShadowStyle globalShadowStyle;


/**
 全局速度 默认1.0
 */
@property (assign, nonatomic) float speed;

/**
 开始计时器 暂停状态就是恢复运动
 */
- (void)start;
- (void)stop;
- (void)pause;

/**
 *  发射弹幕
 *
 *  @param danmaku 单个弹幕
 */
- (void)sendDanmaku:(JHBaseDanmaku *)danmaku;
@end
