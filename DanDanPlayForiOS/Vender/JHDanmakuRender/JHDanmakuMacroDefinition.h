//
//  JHDanmakuMacroDefinition.h
//  OSXDemo
//
//  Created by JimHuang on 16/6/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#ifndef JHDanmakuMacroDefinition_h
#define JHDanmakuMacroDefinition_h

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define JHLabel UILabel
#define jh_attributedText attributedText
#define jh_text text
#define JHColor UIColor
#define JHFont UIFont
#define JHColorBrightness(color) ({ \
CGFloat b;\
[color getHue:nil saturation:nil brightness:&b alpha:nil];\
b;\
})
#define JHView UIView
#define DANMAKU_MAX_CACHE_COUNT 20
#define JHSCALE [UIScreen mainScreen].scale

#else

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#define JHLabel NSTextField
#define jh_attributedText attributedStringValue
#define jh_text stringValue
#define JHColor NSColor
#define JHFont NSFont
#define JHColorBrightness(color) color.brightnessComponent
#define JHView NSView
#define DANMAKU_MAX_CACHE_COUNT 80
#define JHSCALE [NSScreen mainScreen].backingScaleFactor

#endif

#endif /* JHDanmakuMacroDefinition_h */
