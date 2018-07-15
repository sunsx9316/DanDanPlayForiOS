//
//  JHDanmakuContainer.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//  弹幕的容器 用来绘制弹幕


#import "JHFloatDanmaku.h"
#import "JHScrollDanmaku.h"
#import "JHDanmakuDefinition.h"

@class JHDanmakuEngine;
@interface JHDanmakuContainer : JHLabel
/**
 初始位置
 */
@property (assign, nonatomic) CGPoint originalPosition;
@property (weak, nonatomic) JHDanmakuEngine *danmakuEngine;
@property (strong, nonatomic) JHBaseDanmaku *danmaku;

/**
 刷新当前弹幕属性
 */
- (void)updateAttributed;

- (instancetype)initWithDanmaku:(JHBaseDanmaku *)danmaku;
/**
 *  更新位置
 *
 *  @param time 当前时间
 *
 *  @return 是否处于激活状态
 */
- (BOOL)updatePositionWithTime:(NSTimeInterval)time;
@end
