//
//  JHDanmakuClock.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHDanmakuClock.h"
#import "JHDisplayLink.h"
@interface JHDanmakuClock()<JHDisplayLinkDelegate>
@property (strong, nonatomic) JHDisplayLink *displayLink;
@end

@implementation JHDanmakuClock
{
    BOOL _isStart;
    NSTimeInterval _currentTime;
    NSTimeInterval _offsetTime;
    CFTimeInterval _previousDate;
}

- (instancetype)init {
    if (self = [super init]) {
        _speed = 1.0;
    }
    return self;
}

- (void)start {
    _isStart = YES;
    _previousDate = CACurrentMediaTime();
    [self.displayLink start];
}

- (void)stop {
    _previousDate = 0;
    _currentTime = 0.0;
    [self.displayLink pause];
}

- (void)pause {
    _isStart = NO;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    if (currentTime >= 0) {
        _currentTime = currentTime;
    }
}

- (void)setOffsetTime:(NSTimeInterval)offsetTime {
    _offsetTime = offsetTime;
}

- (void)updateTime {
    CFTimeInterval currentDate = CACurrentMediaTime();
    _currentTime += (currentDate - _previousDate) * _speed * _isStart;
    _previousDate = CACurrentMediaTime();
    
    if ([self.delegate respondsToSelector:@selector(danmakuClock:time:)]) {
        [self.delegate danmakuClock:self time:_currentTime + _offsetTime];
    }
}

#pragma mark - JHDisplayLinkDelegate
- (void)displayLinkDidCallback {
    [self updateTime];
}

#pragma mark - 懒加载

- (JHDisplayLink *)displayLink {
    if(_displayLink == nil) {
        _displayLink = [[JHDisplayLink alloc] init];
        _displayLink.delegate = self;
    }
    return _displayLink;
}

@end
