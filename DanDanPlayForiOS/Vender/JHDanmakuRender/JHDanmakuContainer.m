//
//  JHDanmakuContainer.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHDanmakuContainer.h"
#import "JHDanmakuEngine.h"

@implementation JHDanmakuContainer
{
    JHBaseDanmaku *_danmaku;
}

- (instancetype)initWithDanmaku:(JHBaseDanmaku *)danmaku {
    if (self = [super init]) {
//#if !TARGET_OS_IPHONE
//        self.editable = NO;
//        self.drawsBackground = NO;
//        self.bordered = NO;
//#endif
        
        self.contentsScale = JHSCALE;
        [self setWithDanmaku:danmaku];
    }
    return self;
}

- (id<CAAction>)actionForKey:(NSString *)event {
    return nil;
}

- (void)setWithDanmaku:(JHBaseDanmaku *)danmaku {
    _danmaku = danmaku;
    self.foregroundColor = danmaku.textColor.CGColor;
    if (danmaku.attributedString) {
        self.string = danmaku.attributedString;
    }
    else {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:danmaku.text ? danmaku.text : @""];
        self.string = str;
    }
    
//    self.jh_text = danmaku.text ? danmaku.text : @"";
//    self.jh_attributedText = danmaku.attributedString;
    [self updateAttributed];
}

- (BOOL)updatePositionWithTime:(NSTimeInterval)time {
    return [_danmaku updatePositonWithTime:time container:self];
}

- (JHBaseDanmaku *)danmaku {
    return _danmaku;
}

- (void)setOriginalPosition:(CGPoint)originalPosition {
    _originalPosition = originalPosition;
    CGRect rect = self.frame;
    rect.origin = originalPosition;
    self.frame = rect;
}

- (void)updateAttributed {
    
    NSDictionary *globalAttributed = [self.danmakuEngine globalAttributedDic];
    NSAttributedString *str = self.string;
    
    if (globalAttributed && str.length) {
        self.string = [[NSMutableAttributedString alloc] initWithString:str.string attributes:globalAttributed];
//        self.jh_attributedText = [[NSMutableAttributedString alloc] initWithString:self.jh_attributedText.string attributes:globalAttributed];
    }
    
    NSMutableDictionary *originalAttributed = nil;
    if (str.length) {
        originalAttributed = [str attributesAtIndex:0 effectiveRange:nil].mutableCopy;
    }
    else {
        originalAttributed = [NSMutableDictionary dictionary];
    }
    
    JHFont *font = [self.danmakuEngine globalFont];
    if (font) {
        originalAttributed[NSFontAttributeName] = font;
        self.string = [[NSMutableAttributedString alloc] initWithString:str.string attributes:originalAttributed];
//        self.jh_attributedText = [[NSMutableAttributedString alloc] initWithString:self.jh_attributedText.string attributes:originalAttributed];
    }
    
    
    JHDanmakuShadowStyle shadowStyle = [self.danmakuEngine globalShadowStyle];
    if (shadowStyle >= JHDanmakuShadowStyleNone) {
        JHColor *textColor = originalAttributed[NSForegroundColorAttributeName];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[NSFontAttributeName] = originalAttributed[NSFontAttributeName];
        dic[NSForegroundColorAttributeName] = textColor;
        
        switch (shadowStyle) {
            case JHDanmakuShadowStyleGlow:
            {
                NSShadow *shadow = [self shadowWithTextColor:textColor];
                shadow.shadowBlurRadius = 3;
                dic[NSShadowAttributeName] = shadow;
            }
                break;
            case JHDanmakuShadowStyleShadow:
            {
                dic[NSShadowAttributeName] = [self shadowWithTextColor:textColor];
            }
                break;
            case JHDanmakuShadowStyleStroke:
            {
                dic[NSStrokeColorAttributeName] = [self shadowColorWithTextColor:textColor];
                dic[NSStrokeWidthAttributeName] = @-3;
            }
                break;
            default:
                break;
        }
        
        self.string = [[NSMutableAttributedString alloc] initWithString:str.string attributes:dic];
//        self.jh_attributedText = [[NSMutableAttributedString alloc] initWithString:self.jh_attributedText.string attributes:dic];
    }
    
    CGRect frame = self.frame;
    
    frame.size = [(NSAttributedString *)self.string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:kNilOptions context:nil].size;
    self.frame = frame;
//    [self sizeToFit];
}

#pragma mark - 私有方法
- (NSShadow *)shadowWithTextColor:(JHColor *)textColor {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(1, -1);
    shadow.shadowColor = [self shadowColorWithTextColor:textColor];
    return shadow;
}

- (JHColor *)shadowColorWithTextColor:(JHColor *)textColor {
    if (JHColorBrightness(textColor) > 0.5) {
        return [JHColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    return [JHColor colorWithRed:1 green:1 blue:1 alpha:1];
}

@end
