//
//  abstractDanmaku.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHBaseDanmaku.h"
#import "JHDanmakuEngine+Private.h"

@interface JHBaseDanmaku ()
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) JHColor *textColor;
@property (assign, nonatomic) JHDanmakuEffectStyle effectStyle;
@end

@implementation JHBaseDanmaku

- (instancetype)initWithFont:(JHFont *)font
                        text:(NSString *)text
                   textColor:(JHColor *)textColor
                 effectStyle:(JHDanmakuEffectStyle)effectStyle {
    
    if (self = [super init]) {
        //字体为空根据fontSize初始化
        if (!font) font = [JHFont systemFontOfSize: 15];
        if (!text) text = @"";
        if (!textColor) textColor = [JHColor blackColor];
        
        self.text = text;
        self.textColor = textColor;
        self.effectStyle = effectStyle;
    }
    return self;
}

- (BOOL)updatePositonWithTime:(NSTimeInterval)time container:(JHDanmakuContainer *)container {
    return NO;
}

- (CGPoint)originalPositonWithEngine:(JHDanmakuEngine *)engine
                                rect:(CGRect)rect
                         danmakuSize:(CGSize)danmakuSize
                      timeDifference:(NSTimeInterval)timeDifference {
    return CGPointZero;
}

@end

