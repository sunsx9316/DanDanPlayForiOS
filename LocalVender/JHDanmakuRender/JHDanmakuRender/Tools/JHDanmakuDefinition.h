//
//  JHDanmakuDefinition.h
//  OSXDemo
//
//  Created by JimHuang on 16/6/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#ifndef JHDanmakuDefinition_h
#define JHDanmakuDefinition_h

#import <Foundation/Foundation.h>
// 过期提醒
#define JHDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

#ifndef JH_IOS
#define JH_IOS 1
#endif

#ifndef JH_MACOS
#define JH_MACOS 0
#endif

typedef UILabel JHLabel;
typedef UIColor JHColor;
typedef UIFont JHFont;
typedef UIView JHView;

//#define jh_attributedText attributedText
#define jh_text text
#define DANMAKU_MAX_CACHE_COUNT 20

#else

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#ifndef JH_IOS
#define JH_IOS 0
#endif

#ifndef JH_MACOS
#define JH_MACOS 1
#endif

typedef NSTextField JHLabel;
typedef NSColor JHColor;
typedef NSFont JHFont;
typedef NSView JHView;

//#define jh_attributedText attributedStringValue
#define jh_text stringValue
#define DANMAKU_MAX_CACHE_COUNT 80

#endif

#endif /* JHDanmakuDefinition_h */
