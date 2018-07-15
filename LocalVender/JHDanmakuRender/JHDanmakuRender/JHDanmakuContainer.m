//
//  JHDanmakuContainer.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHDanmakuContainer.h"
#import "JHDanmakuEngine.h"
#import "JHDanmakuMethod.h"
#import "JHLabel+Tools.h"

@implementation JHDanmakuContainer
{
    JHBaseDanmaku *_danmaku;
}

- (instancetype)initWithDanmaku:(JHBaseDanmaku *)danmaku {
    if (self = [super init]) {
#if !TARGET_OS_IPHONE
        self.editable = NO;
        self.drawsBackground = NO;
        self.bordered = NO;
#endif
        self.danmaku = danmaku;
    }
    return self;
}

- (id<CAAction>)actionForKey:(NSString *)event {
    return nil;
}

- (void)setDanmaku:(JHBaseDanmaku *)danmaku {
    _danmaku = danmaku;
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:_danmaku.text attributes:[JHDanmakuMethod edgeEffectDicWithStyle:_danmaku.effectStyle textColor:_danmaku.textColor]];
    
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
    
    if (isnan(rect.size.width)) {
        rect.size.width = 0;
    }
    
    if (isnan(rect.size.height)) {
        rect.size.height = 0;
    }
    
    if (isnan(rect.origin.x)) {
        rect.origin.x = 0;
    }
    
    if (isnan(rect.origin.y)) {
        rect.origin.y = 0;
    }
    
    self.frame = rect;
}

- (void)updateAttributed {
    NSDictionary *globalAttributed = [self.danmakuEngine globalAttributedDic];
    JHFont *font = [self.danmakuEngine globalFont];
    JHDanmakuEffectStyle shadowStyle = [self.danmakuEngine globalEffectStyle];
    
    if (self.attributedString.length) {
        NSMutableAttributedString *str = [self.attributedString mutableCopy];
        NSRange range = NSMakeRange(0, str.length);
        
        if (globalAttributed) {
            [str addAttributes:globalAttributed range:range];
        }
        
        if (font) {
            [str addAttributes:@{NSFontAttributeName : font} range:range];
        }
        
        if (shadowStyle > JHDanmakuEffectStyleUndefine) {
            [str removeAttribute:NSShadowAttributeName range:range];
            [str removeAttribute:NSStrokeColorAttributeName range:range];
            [str removeAttribute:NSStrokeWidthAttributeName range:range];
            
            [str addAttributes:[JHDanmakuMethod edgeEffectDicWithStyle:shadowStyle textColor:self.danmaku.textColor] range:range];
        }
        
        self.attributedString = str;
    }
    
    
    [self sizeToFit];
}

@end


