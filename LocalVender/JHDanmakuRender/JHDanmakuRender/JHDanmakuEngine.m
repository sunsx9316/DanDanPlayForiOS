//
//  JHDanmakuEngine.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHDanmakuEngine.h"
#import "JHDanmakuClock.h"
#import "JHDanmakuContainer.h"
#import "JHFloatDanmaku.h"

@interface JHDanmakuEngine()<JHDanmakuClockDelegate>
@property (strong, nonatomic) JHDanmakuClock *clock;
/**
 *  当前未激活的弹幕
 */
@property (strong, nonatomic) NSMutableArray <JHDanmakuContainer *>*inactiveContainer;
/**
 *  当前激活的弹幕
 */
@property (strong, nonatomic) NSMutableArray <JHDanmakuContainer *>*activeContainer;
@end

@implementation JHDanmakuEngine
{
    //用于记录当前时间的整数值
    NSInteger _intTime;
    CGFloat _extraSpeed;
    dispatch_queue_t _queue;
}

- (instancetype)init {
    if (self = [super init]) {
        _intTime = -1;
        _timeInterval = 1;
        _queue = dispatch_queue_create("JHDanmakuEngine.queue", DISPATCH_QUEUE_SERIAL);
        [self setSpeed: 1.0];
    }
    return self;
}

- (void)start {
    [self.clock start];
}

- (void)stop {
    _intTime = -_timeInterval;
    [self.clock stop];
    [self.activeContainer enumerateObjectsUsingBlock:^(JHDanmakuContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.activeContainer removeAllObjects];
}

- (void)pause {
    [self.clock pause];
}

- (void)setTimeInterval:(NSUInteger)timeInterval {
    _timeInterval = timeInterval;
    _intTime = -_timeInterval;
}

- (void)sendDanmaku:(JHBaseDanmaku *)danmaku {
    [self sendDanmaku:danmaku updateAppearTime:YES];
}

- (void)setOffsetTime:(NSTimeInterval)offsetTime {
    _intTime = -_timeInterval;
    [self.clock setOffsetTime:offsetTime];
    [self reloadPreDanmaku];
}

- (NSTimeInterval)offsetTime {
    return self.clock.offsetTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    if (currentTime < 0) return;
    _currentTime = currentTime;
    _intTime = -_timeInterval;
    [self.clock setCurrentTime:currentTime];
    [self reloadPreDanmaku];
}

- (void)setChannelCount:(NSInteger)channelCount {
    if (channelCount >= 0) {
        _channelCount = channelCount;
        [self setCurrentTime:_currentTime];
    }
}

- (void)setSpeed:(CGFloat)speed {
    _extraSpeed = speed > 0 ? speed : 0.1;
    [self.activeContainer enumerateObjectsUsingBlock:^(JHDanmakuContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.danmaku.extraSpeed = _extraSpeed;
    }];
}

- (CGFloat)speed {
    return _extraSpeed;
}

- (void)setSystemSpeed:(CGFloat)systemSpeed {
    self.clock.speed = systemSpeed;
}

- (CGFloat)systemSpeed {
    return self.clock.speed;
}

- (void)setGlobalAttributedDic:(NSDictionary *)globalAttributedDic {
    if ([_globalAttributedDic isEqualToDictionary:globalAttributedDic] == NO) {
        _globalAttributedDic = globalAttributedDic;
        [self reloadCurrentActiveDanmaukus];
    }
}

- (void)setGlobalFont:(JHFont *)globalFont {
    if ([_globalFont isEqual: globalFont] == NO) {
        _globalFont = globalFont;
        [self reloadCurrentActiveDanmaukus];
    }
}

- (void)setGlobalShadowStyle:(JHDanmakuShadowStyle)globalShadowStyle {
    self.globalEffectStyle = (JHDanmakuEffectStyle)globalShadowStyle;
}

- (void)setGlobalEffectStyle:(JHDanmakuEffectStyle)globalEffectStyle {
    if (_globalEffectStyle != globalEffectStyle) {
        _globalEffectStyle = globalEffectStyle;
        [self reloadCurrentActiveDanmaukus];
    }
}

#pragma mark - JHDanmakuClockDelegate
- (void)danmakuClock:(JHDanmakuClock *)clock time:(NSTimeInterval)time {
    //是否启用外部时间
    if ([self.delegate respondsToSelector:@selector(engineTimeSystemFollowWithOuterTimeSystem)]) {
        _currentTime = [self.delegate engineTimeSystemFollowWithOuterTimeSystem];
        _intTime = _currentTime;
        NSArray <JHBaseDanmaku*>*danmakus = [self.delegate danmakuEngine:self didSendDanmakuAtTime:_intTime];
        
        [danmakus enumerateObjectsUsingBlock:^(JHBaseDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self sendDanmaku:obj updateAppearTime:NO];
        }];
    }
    else {
        _currentTime = time;
        //根据间隔获取一次弹幕
        if ([self.delegate respondsToSelector:@selector(danmakuEngine:didSendDanmakuAtTime:)] && (NSInteger)_currentTime - _intTime >= _timeInterval) {
            _intTime = _currentTime;
            NSArray <JHBaseDanmaku*>*danmakus = [self.delegate danmakuEngine:self didSendDanmakuAtTime:_intTime];
            
            [danmakus enumerateObjectsUsingBlock:^(JHBaseDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self sendDanmaku:obj updateAppearTime:NO];
            }];
        }
    }
    
    //遍历激活的弹幕容器 逐一发射
    NSArray <JHDanmakuContainer *>*danmakus = self.activeContainer;
    [danmakus enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHDanmakuContainer * _Nonnull container, NSUInteger idx, BOOL * _Nonnull stop) {
        //如果弹幕移出屏幕或者到达显示时长 则移出画布 状态改为失活
        if ([container updatePositionWithTime:_currentTime] == NO) {
            JHBaseDanmaku *aDanmaku = container.danmaku;
            
            [self.activeContainer removeObjectAtIndex:idx];
            
            if (self.inactiveContainer.count < DANMAKU_MAX_CACHE_COUNT) {
                [self.inactiveContainer addObject:container];
            }
            [container removeFromSuperview];
            aDanmaku.disappearTime = _currentTime;
        }
    }];
}

#pragma mark - 私有方法
//加载当前时间显示的弹幕弹幕
- (void)reloadPreDanmaku {
    if ([self.delegate respondsToSelector:@selector(danmakuEngine:didSendDanmakuAtTime:)]) {
        //移除当前显示的弹幕
        [self.activeContainer enumerateObjectsUsingBlock:^(JHDanmakuContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [self.activeContainer removeAllObjects];
        
        for (NSInteger i = 1; i < 5; ++i) {
            NSInteger time = _currentTime - i;
            NSArray <JHBaseDanmaku *>*danmakus = [self.delegate danmakuEngine:self didSendDanmakuAtTime:time];
            [danmakus enumerateObjectsUsingBlock:^(JHBaseDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self sendDanmaku:obj updateAppearTime:NO];
            }];
        }
    }
}

//重设当前弹幕初始位置
- (void)resetOriginalPosition:(CGRect)bounds {
    [self.activeContainer enumerateObjectsUsingBlock:^(JHDanmakuContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.originalPosition = [obj.danmaku originalPositonWithEngine:self rect:bounds danmakuSize:obj.bounds.size timeDifference:_currentTime - obj.danmaku.appearTime];
    }];
}


/**
 发射弹幕
 
 @param danmaku 弹幕
 @param updateAppearTime 是否更改当前时间为弹幕的时间
 */
- (void)sendDanmaku:(JHBaseDanmaku *)danmaku updateAppearTime:(BOOL)updateAppearTime {
    
    if ([self.delegate respondsToSelector:@selector(danmakuEngine:shouldSendDanmaku:)] && [self.delegate danmakuEngine:self shouldSendDanmaku:danmaku] == NO) {
        return;
    }
    
    //当前弹幕数量大于限制数量
    if (_limitCount > 0 && self.activeContainer.count > _limitCount) {
        return;
    }
    
    if (updateAppearTime) {
        danmaku.appearTime = _currentTime;
    }
    
    //附加速度
    danmaku.extraSpeed = _extraSpeed;
    
    //尝试从缓存中获取弹幕容器 没有则创建一个
    JHDanmakuContainer *con = self.inactiveContainer.firstObject;
    if (con == nil) {
        con = [[JHDanmakuContainer alloc] initWithDanmaku:danmaku];
        con.danmakuEngine = self;
    }
    else {
        [self.inactiveContainer removeObject:con];
    }
    
    con.danmaku = danmaku;
    con.originalPosition = [con.danmaku originalPositonWithEngine:self rect:self.canvas.bounds danmakuSize:con.bounds.size timeDifference:_currentTime - danmaku.appearTime];
    
    [self.canvas addSubview:con];
    //将弹幕容器激活
    [self.activeContainer addObject:con];
}


/**
 刷新当前弹幕属性
 */
- (void)reloadCurrentActiveDanmaukus {
    NSArray <JHDanmakuContainer *>*activeContainer = self.activeContainer;
    [activeContainer enumerateObjectsUsingBlock:^(JHDanmakuContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateAttributed];
    }];
}

#pragma mark - 懒加载
- (JHDanmakuClock *)clock {
    if(_clock == nil) {
        _clock = [[JHDanmakuClock alloc] init];
        _clock.delegate = self;
    }
    return _clock;
}


- (NSMutableArray <JHDanmakuContainer *> *)inactiveContainer {
    if(_inactiveContainer == nil) {
        _inactiveContainer = [NSMutableArray array];
    }
    return _inactiveContainer;
}

- (NSMutableArray <JHDanmakuContainer *> *)activeContainer {
    if(_activeContainer == nil) {
        _activeContainer = [[NSMutableArray <JHDanmakuContainer *> alloc] init];
    }
    return _activeContainer;
}

- (JHDanmakuCanvas *)canvas {
    if(_canvas == nil) {
        _canvas = [[JHDanmakuCanvas alloc] init];
        __weak typeof(self)weakSelf = self;
        [_canvas setResizeCallBackBlock:^(CGRect bounds) {
            __strong typeof(weakSelf)self = weakSelf;
            if (!self) return;
            
            [self resetOriginalPosition:bounds];
        }];
    }
    return _canvas;
}

@end

