//
//  JHDanmakuCanvas.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/2/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHDanmakuCanvas.h"
#import "JHDanmakuPrivateHeader.h"

@implementation JHDanmakuCanvas
- (JHView *)hitTest:(CGPoint)aPoint{
    return nil;
}

- (instancetype)init{
    if (self = [super init]) {
#if JH_IOS
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
#else
        [self setWantsLayer:YES];
        self.autoresizingMask = NSViewMinXMargin | NSViewWidthSizable | NSViewMinYMargin | NSViewHeightSizable;
#endif
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLayoutStyle:(JHDanmakuCanvasLayoutStyle)layoutStyle {
    if (_layoutStyle == layoutStyle) {
        return;
    }
    
#if JH_MACOS
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _layoutStyle = layoutStyle;
    switch (_layoutStyle) {
        case JHDanmakuCanvasLayoutStyleWhenSizeChanged:
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize:) name:NSWindowDidEndLiveResizeNotification object:nil];
            break;
        case JHDanmakuCanvasLayoutStyleWhenSizeChanging:
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize:) name:NSWindowDidResizeNotification object:nil];
            break;
        default:
            break;
    }
#endif
}

- (void)resize:(NSNotification *)sender {
    if (self.resizeCallBackBlock) {
        self.resizeCallBackBlock(self.bounds);
    }
}


/**
 翻转mac原点
 */
- (BOOL)isFlipped {
    return YES;
}

@end
