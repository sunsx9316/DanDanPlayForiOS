//
//  JHDanmakuMethod.h
//  JHDanmakuRender
//
//  Created by JimHuang on 2018/5/1.
//

#import <Foundation/Foundation.h>
#import "JHDanmakuDefinition.h"
#import "JHBaseDanmaku.h"

/**
 屏幕缩放比例

 @return 屏幕缩放比例
 */
FOUNDATION_EXPORT CGFloat jh_scale(void);

/**
 获取颜色亮度

 @param color 颜色
 @return 亮度
 */
FOUNDATION_EXPORT CGFloat jh_colorBrightness(JHColor *color);


/**
 颜色

 @param r 红
 @param g 绿
 @param b 蓝
 @return 颜色
 */
FOUNDATION_EXPORT JHColor *jh_RGBColor(int r, int g, int b);

/**
 颜色

 @param r 红
 @param g 绿
 @param b 蓝
 @param a 透明度
 @return 颜色
 */
FOUNDATION_EXPORT JHColor *jh_RGBAColor(int r, int g, int b, CGFloat a);

@interface JHDanmakuMethod: NSObject

/**
 根据颜色生成阴影

 @param color 颜色
 @return 阴影
 */
+ (NSShadow *)shadowWithColor:(JHColor *)color;

/**
 根据颜色生成合适的阴影颜色

 @param color 颜色
 @return 阴影颜色
 */
+ (JHColor *)shadowColorWithColor:(JHColor *)color;

/**
 边缘特效字典

 @param style 特效
 @param color 颜色
 @return 边缘特效字典
 */
+ (NSDictionary *)edgeEffectDicWithStyle:(JHDanmakuEffectStyle)style
                               textColor:(JHColor *)color;

@end

