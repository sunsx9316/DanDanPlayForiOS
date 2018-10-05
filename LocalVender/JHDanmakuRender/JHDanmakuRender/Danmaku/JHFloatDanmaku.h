//
//  JHFloatDanmaku.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//
#import "JHBaseDanmaku.h"
#import "JHDanmakuDefinition.h"

/**
 浮动弹幕位置
 
 - JHFloatDanmakuPositionAtBottom: 在底部
 - JHFloatDanmakuPositionAtTop: 在顶部
 */
typedef NS_ENUM(NSUInteger, JHFloatDanmakuPosition) {
    JHFloatDanmakuPositionAtBottom = 100,
    JHFloatDanmakuPositionAtTop
};

typedef NS_ENUM(NSUInteger, JHFloatDanmakuDirection) {
    JHFloatDanmakuDirectionB2T = JHFloatDanmakuPositionAtBottom,
    JHFloatDanmakuDirectionT2B = JHFloatDanmakuPositionAtTop
} JHDeprecated("使用 JHFloatDanmakuPosition");


@interface JHFloatDanmaku : JHBaseDanmaku
/**
 *  初始化 阴影 字体
 *
 *  @param fontSize    文字大小
 *  @param textColor   文字颜色(务必使用 colorWithRed:green:blue:alpha初始化)
 *  @param text        文本
 *  @param shadowStyle 阴影类型
 *  @param font        字体
 *  @param during      弹幕持续时间
 *  @param direction   弹幕方向
 *
 *  @return self
 */
- (instancetype)initWithFontSize:(CGFloat)fontSize
                       textColor:(JHColor *)textColor
                            text:(NSString *)text
                     shadowStyle:(JHDanmakuShadowStyle)shadowStyle
                            font:(JHFont *)font
                          during:(CGFloat)during
                       direction:(JHFloatDanmakuDirection)direction JHDeprecated("使用 initWithFont:text:textColor:effectStyle:during:position");

/**
 *  初始化 阴影 字体
 *
 *  @param font        字体
 *  @param text        文本
 *  @param textColor   文字颜色(务必使用 colorWithRed:green:blue:alpha初始化)
 *  @param effectStyle 阴影类型
 *  @param during      弹幕持续时间
 *  @param position   弹幕方向
 *
 *  @return self
 */
- (instancetype)initWithFont:(JHFont *)font
                        text:(NSString *)text
                   textColor:(JHColor *)textColor
                 effectStyle:(JHDanmakuEffectStyle)effectStyle
                      during:(CGFloat)during
                    position:(JHFloatDanmakuPosition)position;

- (JHFloatDanmakuDirection)direction JHDeprecated("使用 position");

@property (assign, nonatomic, readonly) CGFloat during;
@property (assign, nonatomic, readonly) JHFloatDanmakuPosition position;

/**
 计算当前窗口所能容纳的轨道数量
 
 @param contentRect 窗口大小
 @param danmakuSize 弹幕大小
 @return 当前窗口所能容纳的轨道数量
 */
- (NSInteger)channelCountWithContentRect:(CGRect)contentRect danmakuSize:(CGSize)danmakuSize;

/**
 计算当前轨道高度
 
 @param channelCount 轨道数量
 @param rect 窗口尺寸
 @return 当前轨道高度
 */
- (NSInteger)channelHeightWithChannelCount:(NSInteger)channelCount contentRect:(CGRect)rect;

@end

