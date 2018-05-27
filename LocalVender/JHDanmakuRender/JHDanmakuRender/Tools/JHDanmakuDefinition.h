//
//  JHDanmakuDefinition.h
//  OSXDemo
//
//  Created by JimHuang on 16/6/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JHDanmakuEffectStyle) {
    JHDanmakuEffectStyleUndefine = 0,
    //啥也没有
    JHDanmakuEffectStyleNone = 100,
    //描边
    JHDanmakuEffectStyleStroke,
    //投影
    JHDanmakuEffectStyleShadow,
    //模糊阴影
    JHDanmakuEffectStyleGlow,
};

#ifdef DEBUG
#define danmaku_log(...) //NSLog(__VA_ARGS__)
#else
#define danmaku_log(...)
#endif

#if TARGET_OS_OSX

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#define JH_MAC_OS 1

typedef NSColor JHColor;
typedef NSFont JHFont;
typedef NSView JHView;
typedef NSTextField JHLabel;

#define jh_text stringValue

#define DANMAKU_MAX_CACHE_COUNT 80

#else
#import <UIKit/UIKit.h>

#define JH_IOS 1

typedef UIColor JHColor;
typedef UIFont JHFont;
typedef UIView JHView;
typedef UILabel JHLabel;

#define jh_text text

#define DANMAKU_MAX_CACHE_COUNT 20

#endif

