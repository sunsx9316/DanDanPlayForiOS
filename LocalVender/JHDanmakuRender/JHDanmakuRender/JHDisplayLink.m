//
//  JHDisplayLink.m
//  JHDanmakuRender
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHDisplayLink.h"
#import "JHDanmakuDefinition.h"

#ifdef JH_MAC_OS
#import <CoreVideo/CVDisplayLink.h>
#else
#import <CoreGraphics/CoreGraphics.h>
#endif


@interface JHDisplayLink ()

@end

@implementation JHDisplayLink
{
#ifdef JH_IOS
    CADisplayLink *_IOSDisplayLink;
#else
    CVDisplayLinkRef _OSXDisplayLink;
#endif
}

- (instancetype)init{
    if (self = [super init]) {
#ifdef JH_MAC_OS
        CVReturn status = CVDisplayLinkCreateWithActiveCGDisplays(&_OSXDisplayLink);
        NSAssert(status == kCVReturnSuccess, @"初始化失败");
        __weak typeof(self) weakSelf = self;
        CVDisplayLinkSetOutputHandler(_OSXDisplayLink, ^CVReturn(CVDisplayLinkRef  _Nonnull displayLink, const CVTimeStamp * _Nonnull inNow, const CVTimeStamp * _Nonnull inOutputTime, CVOptionFlags flagsIn, CVOptionFlags * _Nonnull flagsOut) {
            __strong typeof(weakSelf) self = weakSelf;
            if (self == nil) return kCVReturnError;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate displayLinkDidCallback];
            });
            
            return kCVReturnSuccess;
        });
        
#endif
    }
    
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
#if JH_IOS
    [self stop];
    _IOSDisplayLink = [CADisplayLink displayLinkWithTarget:self.delegate selector:@selector(displayLinkDidCallback)];
    [_IOSDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
#else
    if (CVDisplayLinkIsRunning(_OSXDisplayLink)) {
        return;
    }
    
    CVDisplayLinkStart(_OSXDisplayLink);
#endif
}

- (void)pause {
#if JH_IOS
    if (_IOSDisplayLink.isPaused == false) {
        _IOSDisplayLink.paused = true;
    }
#else
    if (CVDisplayLinkIsRunning(_OSXDisplayLink) == false) {
        return;
    }
    
    CVDisplayLinkStop(_OSXDisplayLink);
#endif
}

- (void)stop {
#if JH_IOS
    [_IOSDisplayLink invalidate];
#else
    if (_OSXDisplayLink) {
        CVDisplayLinkRelease(_OSXDisplayLink);
        _OSXDisplayLink = nil;
    }
#endif
}

@end
