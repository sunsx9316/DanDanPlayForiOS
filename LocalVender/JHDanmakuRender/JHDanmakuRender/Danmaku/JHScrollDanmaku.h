//
//  JHScrollDanmaku.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHBaseDanmaku.h"

/**
 滚动弹幕方向

 - JHScrollDanmakuDirectionR2L: 从右到左
 - JHScrollDanmakuDirectionL2R: 从左到右
 - JHScrollDanmakuDirectionT2B: 从上到下
 - JHScrollDanmakuDirectionB2T: 从下到上
 */
typedef NS_ENUM(NSInteger, JHScrollDanmakuDirection) {
    JHScrollDanmakuDirectionR2L = 10,
    JHScrollDanmakuDirectionL2R = 11,
    JHScrollDanmakuDirectionT2B = 20,
    JHScrollDanmakuDirectionB2T = 21,
};

@interface JHScrollDanmaku : JHBaseDanmaku
/**
 *  初始化 阴影 字体
 *
 *  @param font        字体
 *  @param text        文本内容
 *  @param textColor   文字颜色(务必使用 colorWithRed:green:blue:alpha初始化)
 *  @param effectStyle 阴影风格
 *  @param speed       弹幕速度
 *  @param direction   弹幕运动方向
 *
 *  @return self
 */

- (instancetype)initWithFont:(JHFont *)font
                        text:(NSString *)text
                   textColor:(JHColor *)textColor
                 effectStyle:(JHDanmakuEffectStyle)effectStyle
                       speed:(CGFloat)speed
                   direction:(JHScrollDanmakuDirection)direction;

@property (assign, nonatomic, readonly) CGFloat speed;
@property (assign, nonatomic, readonly) JHScrollDanmakuDirection direction;



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

/**
 *  计算弹幕所在轨道
 *
 *  @param frame         弹幕 frame
 *  @param channelHeight 轨道高
 *
 *  @return 轨道
 */
- (NSInteger)channelWithFrame:(CGRect)frame channelHeight:(CGFloat)channelHeight;
@end

