//
//  JHScrollDanmaku.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHBaseDanmaku.h"

typedef NS_ENUM(NSUInteger, JHScrollDanmakuDirection) {
    JHScrollDanmakuDirectionR2L = 10,
    JHScrollDanmakuDirectionL2R,
    JHScrollDanmakuDirectionT2B,
    JHScrollDanmakuDirectionB2T,
};

@interface JHScrollDanmaku : JHBaseDanmaku
/**
 *  初始化 阴影 字体
 *
 *  @param fontSize    文字大小(在font为空时有效)
 *  @param textColor   文字颜色(务必使用 colorWithRed:green:blue:alpha初始化)
 *  @param text        文本内容
 *  @param shadowStyle 阴影风格
 *  @param font        字体
 *  @param speed       弹幕速度
 *  @param direction   弹幕运动方向
 *
 *  @return self
 */
- (instancetype)initWithFontSize:(CGFloat)fontSize textColor:(JHColor *)textColor text:(NSString *)text shadowStyle:(JHDanmakuShadowStyle)shadowStyle font:(JHFont *)font speed:(CGFloat)speed direction:(JHScrollDanmakuDirection)direction;
- (CGFloat)speed;
- (JHScrollDanmakuDirection)direction;
@end
