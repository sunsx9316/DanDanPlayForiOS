//
//  JHScrollDanmaku.m
//  JHDanmakuRenderDemo
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHScrollDanmaku.h"
#import "JHDanmakuContainer.h"
#import "JHDanmakuEngine+Private.h"
#import "JHDanmakuChannel.h"

@interface JHScrollDanmaku()
@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) JHScrollDanmakuDirection direction;
@end

@implementation JHScrollDanmaku
{
    NSInteger _currentChannel;
}

- (instancetype)initWithFont:(JHFont *)font
                        text:(NSString *)text
                   textColor:(JHColor *)textColor
                 effectStyle:(JHDanmakuEffectStyle)effectStyle
                       speed:(CGFloat)speed
                   direction:(JHScrollDanmakuDirection)direction {
    if (self = [super initWithFont:font text:text textColor:textColor effectStyle:effectStyle]) {
        self.speed = speed;
        self.direction = direction;
    }
    return self;
}

- (BOOL)updatePositonWithTime:(NSTimeInterval)time container:(JHDanmakuContainer *)container {
    CGRect windowFrame = container.danmakuEngine.canvas.bounds;
    CGRect containerFrame = container.frame;
    CGPoint point = container.originalPosition;
    
    switch (_direction) {
        case JHScrollDanmakuDirectionR2L:
        {
            point.x -= (_speed * self.extraSpeed) * (time - self.appearTime);
            containerFrame.origin = point;
            container.frame = containerFrame;
            return CGRectGetMaxX(containerFrame) >= 0;
        }
        case JHScrollDanmakuDirectionL2R:
        {
            point.x += (_speed * self.extraSpeed) * (time - self.appearTime);
            containerFrame.origin = point;
            container.frame = containerFrame;
            return containerFrame.origin.x <= windowFrame.size.width;
        }
        case JHScrollDanmakuDirectionB2T:
        {
            point.y -= (_speed * self.extraSpeed) * (time - self.appearTime);
            containerFrame.origin = point;
            container.frame = containerFrame;
            return CGRectGetMaxY(containerFrame) >= 0;
        }
        case JHScrollDanmakuDirectionT2B:
        {
            point.y += (_speed * self.extraSpeed) * (time - self.appearTime);
            containerFrame.origin = point;
            container.frame = containerFrame;
            return containerFrame.origin.y <= windowFrame.size.height;
        }
    }
    return NO;
}

/**
 *
 遍历所有同方向的弹幕
 如果方向是左右或者右左 channelHeight = 窗口高/channelCount
 如果是上下或者下上 channelHeight = 窗口宽/channelCount
 左右方向按照y/channelHeight 归类
 上下方向按照x/channelHeight 归类
 优先选择没有弹幕的轨道
 如果都有 计算选择弹幕最少的轨道 如果所有轨道弹幕数相同 则随机选择一条
 */
- (CGPoint)originalPositonWithEngine:(JHDanmakuEngine *)engine
                                rect:(CGRect)rect
                         danmakuSize:(CGSize)danmakuSize
                      timeDifference:(NSTimeInterval)timeDifference {
    NSMutableDictionary <NSNumber *, JHDanmakuChannel *>*dic = [NSMutableDictionary dictionary];
    
    NSInteger channelCount = (engine.channelCount == 0) ? [self channelCountWithContentRect:rect danmakuSize:danmakuSize] : engine.channelCount;
    NSMutableArray <JHDanmakuContainer *>*activeContainer = engine.activeContainer;
    
    //轨道高
    NSInteger channelHeight = [self channelHeightWithChannelCount:channelCount contentRect:rect];
    
    CGRect contentFrame = engine.canvas.frame;
    
    [activeContainer enumerateObjectsUsingBlock:^(JHDanmakuContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.danmaku isKindOfClass:[JHScrollDanmaku class]]) {
            JHScrollDanmaku *aDanmaku = (JHScrollDanmaku *)obj.danmaku;
            //同方向
            if (labs(self.direction - aDanmaku.direction) <= 1) {
                NSNumber *channelNum = @(aDanmaku.currentChannel);
                JHDanmakuChannel *channel = dic[channelNum];
                if (channel == nil) {
                    channel = [[JHDanmakuChannel alloc] init];
                    dic[channelNum] = channel;
                }
                
                channel.danmakusCount++;
                
                JHDanmakuChannelParameter *aChannelParameter = [[JHDanmakuChannelParameter alloc] init];
                //弹幕与屏幕相交的区域
                aChannelParameter.frame = CGRectIntersection(obj.frame, contentFrame);
//                aChannelParameter.speed = aDanmaku.speed;
                
                [channel.danmakuParameters enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHDanmakuChannelParameter * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                    CGRect area = obj1.frame;
                    CGRect aChannelParameterFrame = aChannelParameter.frame;
                    //弹幕区域重叠
                    if (CGRectIntersectsRect(area, aChannelParameterFrame)) {
                        aChannelParameter.frame = CGRectUnion(area, aChannelParameterFrame);
//                        aChannelParameter.speed = (obj1.speed + aChannelParameter.speed) / 2;
                        [channel.danmakuParameters removeObjectAtIndex:idx1];
                    }
                }];
                
                [channel.danmakuParameters addObject:aChannelParameter];
            }
        }
    }];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, JHDanmakuChannel * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.danmakuParameters.count) {
            [obj.danmakuParameters enumerateObjectsUsingBlock:^(JHDanmakuChannelParameter * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                obj.occupancyRate += self.direction < JHScrollDanmakuDirectionT2B ? obj1.frame.size.width : obj1.frame.size.height;
//                obj.averageSpeed += obj1.speed;
            }];
            
            obj.occupancyRate /= self.direction < JHScrollDanmakuDirectionT2B ? contentFrame.size.width : contentFrame.size.height;
//            obj.averageSpeed /= obj.danmakuParameters.count;
        }
    }];
    
    NSInteger channel = 0;
    CGFloat priority = -1;
    
    for (NSInteger i = 0; i < channelCount; ++i) {
        JHDanmakuChannel *obj = dic[@(i)];
        CGFloat aPriority = 0;
        if (obj == nil) {
            aPriority = 0.76;
//            NSLog(@"%ld %f", i, aPriority);
        }
        else {
            //覆盖率越低 优先级越高
            CGFloat occupancyRate = (1.0 - obj.occupancyRate) * 0.3;
            //数量越少 优先级越高 
            CGFloat countRate = (1.0 - MIN((obj.danmakusCount * 1.0 / 5.0), 1.0)) * 0.4;
            //越靠上优先级越高
            CGFloat channelRate = (1.0 - (i * 1.0 / channelCount)) * 0.3;
//            CGFloat speedRate = MIN(fabs(obj.averageSpeed - self.speed), 50.0) / 50.0 * 0.3;
            //计算轨道优先级
            aPriority = occupancyRate + countRate + channelRate;
            danmaku_log(@"%ld %f %f %f %f", i, occupancyRate, countRate, channelRate, aPriority);
        }
        
        
        //轨道优先级越大 选择机会越大
        if (aPriority > priority) {
            priority = aPriority;
            channel = i;
        }
    }
    
    _currentChannel = channel;
    danmaku_log(@"\n====== \n选择：%ld %f \n=======\n",_currentChannel, priority);
    
    switch (_direction) {
        case JHScrollDanmakuDirectionR2L:
            return CGPointMake(rect.size.width - timeDifference * (_speed * self.extraSpeed), channelHeight * channel);
        case JHScrollDanmakuDirectionL2R:
            return CGPointMake(-danmakuSize.width + timeDifference * (_speed * self.extraSpeed), channelHeight * channel);
        case JHScrollDanmakuDirectionB2T:
            return CGPointMake(channelHeight * channel, rect.size.height - timeDifference * (_speed * self.extraSpeed));
        case JHScrollDanmakuDirectionT2B:
            return CGPointMake(channelHeight * channel, -danmakuSize.height + timeDifference * (_speed * self.extraSpeed));
        default:
            return CGPointMake(rect.size.width, rect.size.height);
    }
}

- (CGFloat)speed {
    return _speed;
}

- (JHScrollDanmakuDirection)direction {
    return _direction;
}

- (NSInteger)currentChannel {
    return _currentChannel;
}

#pragma mark - 私有方法
- (NSInteger)channelCountWithContentRect:(CGRect)contentRect danmakuSize:(CGSize)danmakuSize {
    NSInteger channelCount = 0;
    if (_direction == JHScrollDanmakuDirectionL2R || _direction == JHScrollDanmakuDirectionR2L) {
        channelCount = contentRect.size.height / danmakuSize.height;
        return channelCount > 4 ? channelCount : 4;
    }
    channelCount = contentRect.size.width / danmakuSize.width;
    return channelCount > 4 ? channelCount : 4;
}

- (NSInteger)channelHeightWithChannelCount:(NSInteger)channelCount contentRect:(CGRect)rect {
    if (_direction == JHScrollDanmakuDirectionL2R || _direction == JHScrollDanmakuDirectionR2L) {
        return (NSInteger)(rect.size.height / channelCount);
    }
    else {
        return (NSInteger)(rect.size.width / channelCount);
    }
}

- (NSInteger)channelWithFrame:(CGRect)frame channelHeight:(CGFloat)channelHeight {
    if (_direction == JHScrollDanmakuDirectionL2R || _direction == JHScrollDanmakuDirectionR2L) {
        return (NSInteger)(frame.origin.y / channelHeight);
    }
    else {
        return (NSInteger)(frame.origin.x / channelHeight);
    }
}

@end
