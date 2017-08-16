//
//  JHDanmakuContainer.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//  弹幕的容器 用来绘制弹幕


#import "JHFloatDanmaku.h"
#import "JHScrollDanmaku.h"
#import "JHDanmakuMacroDefinition.h"

@class JHDanmakuEngine;
@interface JHDanmakuContainer : CATextLayer
@property (assign, nonatomic) CGPoint originalPosition;
@property (weak, nonatomic) JHDanmakuEngine *danmakuEngine;
- (void)updateAttributed;

- (JHBaseDanmaku *)danmaku;
- (instancetype)initWithDanmaku:(JHBaseDanmaku *)danmaku;
- (void)setWithDanmaku:(JHBaseDanmaku *)danmaku;
/**
 *  更新位置
 *
 *  @param time 当前时间
 *
 *  @return 是否处于激活状态
 */
- (BOOL)updatePositionWithTime:(NSTimeInterval)time;
@end
