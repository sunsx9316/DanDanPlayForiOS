//
//  JHDisplayLink.m
//  CocoaUtils
//
//  Created by Nick Hutchinson on 01/05/2013.
//
//

#import "JHDisplayLink.h"
#import "JHDanmakuPrivateHeader.h"

#if JH_IOS
#import <UIKit/UIKit.h>
#else
#import <CoreVideo/CVDisplayLink.h>
#endif

typedef NS_ENUM(NSUInteger, JHDisplayLinkAtomicFlags) {
    kJHDisplayLinkIsRendering = 1u << 0
};


@interface JHDisplayLink () {
#if JH_IOS
    CADisplayLink *_IOSDisplayLink;
#else
    
    CVDisplayLinkRef _displayLink;
    CVTimeStamp _timeStamp;
    
    JHDisplayLinkAtomicFlags _atomicFlags;
    bool _isRunning;
    
    dispatch_queue_t _internalDispatchQueue;
    dispatch_queue_t _stateChangeQueue;
    dispatch_queue_t _clientDispatchQueue;
#endif
    
}

@end

@implementation JHDisplayLink

- (instancetype)init{
    if (self = [super init]) {
#if JH_MACOS
        CVReturn status =
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        assert(status == kCVReturnSuccess);
        
        _stateChangeQueue = dispatch_queue_create("JHDisplayLink.stateChange", NULL);
        _clientDispatchQueue = dispatch_get_main_queue();
        _internalDispatchQueue = dispatch_queue_create("JHDisplayLink", NULL);
        dispatch_set_target_queue(_internalDispatchQueue, _clientDispatchQueue);
        
        CVDisplayLinkSetOutputCallback(_displayLink, JHDisplayLinkCallback, (__bridge void * _Nullable)(self));
#endif
    }
    
    return self;
}

- (void)dealloc {
#if JH_IOS
    [self stop];
#else
    CVDisplayLinkRelease(_displayLink);
    _internalDispatchQueue = nil;
    _stateChangeQueue = nil;
#endif
}

- (void)start {
#if JH_IOS
    [self stop];
    SEL selector = @selector(displayLinkDidCallback);
    if ([self.delegate respondsToSelector:selector]) {
        _IOSDisplayLink = [CADisplayLink displayLinkWithTarget:self.delegate selector:selector];
        [_IOSDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
#else
    dispatch_async(_stateChangeQueue, ^{
        if (_isRunning)
            return;
        
        _isRunning = true;
        CFRetain((__bridge CFTypeRef)self);
        
        CVDisplayLinkStart(_displayLink);
    });
#endif
}

- (void)stop {
#if JH_IOS
    if (_IOSDisplayLink) {
        [_IOSDisplayLink invalidate];
    }
#else
    dispatch_async(_stateChangeQueue, ^{
        if (!_isRunning) return;
        _isRunning = false;
        dispatch_suspend(_stateChangeQueue);
    });
#endif
}

#if JH_MACOS
- (void)setDispatchQueue:(dispatch_queue_t)dispatchQueue {
    dispatch_set_target_queue(_internalDispatchQueue, dispatchQueue);
    _clientDispatchQueue = dispatchQueue;
}

static CVReturn JHDisplayLinkCallback(CVDisplayLinkRef displayLink,
                      const CVTimeStamp *inNow,
                      const CVTimeStamp *inOutputTime,
                      CVOptionFlags flagsIn,
                      CVOptionFlags *flagsOut,
                      void *ctx) {
    JHDisplayLink *self = (__bridge JHDisplayLink*)ctx;
    
    if (!self->_isRunning) {
        CVDisplayLinkStop(displayLink);
        dispatch_resume(self->_stateChangeQueue);
        CFRelease(ctx);
        
    } else if (!__sync_fetch_and_or(&self->_atomicFlags,
                                    kJHDisplayLinkIsRendering)) {
        self->_timeStamp = *inOutputTime;
        dispatch_async_f(self->_internalDispatchQueue,
                         (void *)CFBridgingRetain(self),
                         JHDisplayLinkRender);
    }
    
    return kCVReturnSuccess;
}

static void JHDisplayLinkRender(void *ctx) {
    JHDisplayLink *self = CFBridgingRelease(ctx);
    if (self->_isRunning) {
        [self->_delegate displayLinkDidCallback];
    }
    __sync_fetch_and_and(&self->_atomicFlags, ~kJHDisplayLinkIsRendering);
}

#endif

@end
