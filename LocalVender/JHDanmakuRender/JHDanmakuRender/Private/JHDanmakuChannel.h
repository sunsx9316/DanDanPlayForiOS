//
//  JHDanmakuChannel.h
//  iOSDemo
//
//  Created by Developer2 on 2017/11/14.
//  Copyright © 2017年 jim. All rights reserved.
//

#import "JHDanmakuDefinition.h"

@interface JHDanmakuChannelParameter : NSObject
/**
 弹幕尺寸
 */
@property (nonatomic, assign) CGRect frame;

/**
 平均速度
 */
@property (nonatomic, assign) CGFloat speed;
@end

@interface JHDanmakuChannel : NSObject

/**
 覆盖率
 */
@property (nonatomic, assign) CGFloat occupancyRate;

/**
 平均速度
 */
@property (nonatomic, assign) CGFloat averageSpeed;

/**
 轨道弹幕数量
 */
@property (nonatomic, assign) NSUInteger danmakusCount;

@property (nonatomic, strong) NSMutableArray <JHDanmakuChannelParameter *>*danmakuParameters;
@end
