//
//  abstractDanmaku.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHBaseDanmaku.h"
#import "JHDanmakuEngine+Private.h"
#import "JHDanmakuPrivateHeader.h"

@implementation JHBaseDanmaku

- (instancetype)initWithFontSize:(CGFloat)fontSize textColor:(JHColor *)textColor text:(NSString *)text shadowStyle:(JHDanmakuShadowStyle)shadowStyle font:(JHFont *)font{
    if (!font) font = [JHFont systemFontOfSize: fontSize];
    return [self initWithFont:font text:text textColor:textColor effectStyle:(JHDanmakuEffectStyle)shadowStyle];
}

- (instancetype)initWithFont:(JHFont *)font
                        text:(NSString *)text
                   textColor:(JHColor *)textColor
                 effectStyle:(JHDanmakuEffectStyle)effectStyle {
    if (self = [super init]) {
        //字体为空根据fontSize初始化
        if (!font) font = [JHFont systemFontOfSize: 15];
        if (!text) text = @"";
        if (!textColor) textColor = [JHColor blackColor];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[NSFontAttributeName] = font;
        dic[NSForegroundColorAttributeName] = textColor;

        [dic addEntriesFromDictionary:[JHDanmakuMethod edgeEffectDicWithStyle:effectStyle textColor:textColor]];
        
        _font = font;
        self.attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:dic];
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

- (NSString *)text {
    return _attributedString.string;
}

- (JHColor *)textColor {
    if (!_attributedString.length) return nil;
    
    return [_attributedString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
}

- (NSAttributedString *)attributedString {
    return _attributedString;
}

@end

