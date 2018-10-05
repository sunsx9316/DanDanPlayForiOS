//
//  abstractDanmaku.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHDanmakuDefinition.h"

@class JHDanmakuContainer, JHDanmakuEngine;

typedef NS_ENUM(NSUInteger, JHDanmakuEffectStyle) {
    JHDanmakuEffectStyleUndefine = 0,
    //啥也没有
    JHDanmakuEffectStyleNone = 100,
    //描边
    JHDanmakuEffectStyleStroke,
    //投影
    JHDanmakuEffectStyleShadow,
    //模糊阴影
    JHDanmakuEffectStyleGlow,
};


typedef NS_ENUM(NSUInteger, JHDanmakuShadowStyle) {
    JHDanmakuShadowStyleUndefine = JHDanmakuEffectStyleUndefine,
    //啥也没有
    JHDanmakuShadowStyleNone = JHDanmakuEffectStyleNone,
    //描边
    JHDanmakuShadowStyleStroke = JHDanmakuEffectStyleStroke,
    //投影
    JHDanmakuShadowStyleShadow = JHDanmakuEffectStyleShadow,
    //模糊阴影
    JHDanmakuShadowStyleGlow = JHDanmakuEffectStyleGlow,
} JHDeprecated("使用 JHDanmakuEffectStyle");

@interface JHBaseDanmaku : NSObject
@property (strong, nonatomic, readonly) JHFont *font;
@property (assign, nonatomic) NSTimeInterval appearTime;
@property (assign, nonatomic) NSTimeInterval disappearTime;
//额外的速度 用于调节全局速度时更改个体速度 目前只影响滚动弹幕
@property (assign, nonatomic) float extraSpeed;
@property (strong, nonatomic) NSAttributedString *attributedString;
//当前所在轨道
@property (assign, nonatomic) NSInteger currentChannel;

- (NSString *)text;
- (JHColor *)textColor;

/**
 计算弹幕初始位置
 
 @param engine 弹幕引擎
 @param rect 显示范围
 @param danmakuSize 弹幕尺寸
 @param timeDifference 时间差
 @return 初始位置
 */
- (CGPoint)originalPositonWithEngine:(JHDanmakuEngine *)engine
                                rect:(CGRect)rect
                         danmakuSize:(CGSize)danmakuSize
                      timeDifference:(NSTimeInterval)timeDifference;

/**
 *  更新位置
 *
 *  @param time      当前时间
 *  @param container 容器
 *
 *  @return 是否处于激活状态
 */
- (BOOL)updatePositonWithTime:(NSTimeInterval)time
                    container:(JHDanmakuContainer *)container;
/**
 *  父类方法 不要使用
 */
- (instancetype)initWithFontSize:(CGFloat)fontSize
                       textColor:(JHColor *)textColor
                            text:(NSString *)text
                     shadowStyle:(JHDanmakuShadowStyle)shadowStyle
                            font:(JHFont *)font JHDeprecated("请使用 - initWithFont:text:textColor:effectStyle");

/**
 *  父类方法 不要使用
 */
- (instancetype)initWithFont:(JHFont *)font
                        text:(NSString *)text
                   textColor:(JHColor *)textColor
                 effectStyle:(JHDanmakuEffectStyle)effectStyle;


@end

