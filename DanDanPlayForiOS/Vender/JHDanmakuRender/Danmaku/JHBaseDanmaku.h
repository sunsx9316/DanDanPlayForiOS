//
//  abstractDanmaku.h
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHDanmakuMacroDefinition.h"

@class JHDanmakuContainer;
typedef NS_ENUM(NSUInteger, JHDanmakuShadowStyle) {
    //啥也没有
    JHDanmakuShadowStyleNone = 100,
    //描边
    JHDanmakuShadowStyleStroke,
    //投影
    JHDanmakuShadowStyleShadow,
    //模糊阴影
    JHDanmakuShadowStyleGlow,
};

@interface JHBaseDanmaku : NSObject
@property (assign, nonatomic) NSTimeInterval appearTime;
@property (assign, nonatomic) NSTimeInterval disappearTime;
//额外的速度 用于调节全局速度时更改个体速度 目前只影响滚动弹幕
@property (assign, nonatomic) float extraSpeed;
@property (strong, nonatomic) NSAttributedString *attributedString;

- (NSString *)text;
- (JHColor *)textColor;
- (CGPoint)originalPositonWithContainerArr:(NSArray <JHDanmakuContainer *>*)arr channelCount:(NSInteger)channelCount contentRect:(CGRect)rect danmakuSize:(CGSize)danmakuSize timeDifference:(NSTimeInterval)timeDifference;
/**
 *  更新位置
 *
 *  @param time      当前时间
 *  @param container 容器
 *
 *  @return 是否处于激活状态
 */
- (BOOL)updatePositonWithTime:(NSTimeInterval)time container:(JHDanmakuContainer *)container;
/**
 *  父类方法 不要使用
 */
- (instancetype)initWithFontSize:(CGFloat)fontSize textColor:(JHColor *)textColor text:(NSString *)text shadowStyle:(JHDanmakuShadowStyle)shadowStyle font:(JHFont *)font;


@end
