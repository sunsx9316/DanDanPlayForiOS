//
//  DanMuModel.h
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

typedef NS_ENUM(NSUInteger, DDPDanmakuMode) {
    DDPDanmakuModeNormal = 1,
    DDPDanmakuModeBottom = 4,
    DDPDanmakuModeTop = 5,
};

@interface DDPDanmaku : DDPBase

/*
 
 identity -> CId 弹幕编号，此编号在同一个弹幕库中唯一，且新弹幕永远比旧弹幕编号要大。
 
 */

/**
 *  Time: 浮点数形式的弹幕时间，单位为秒。
 */
@property (nonatomic, assign) NSTimeInterval time;
/**
 *  Mode: 弹幕模式，1普通弹幕，4底部弹幕，5顶部弹幕。
 */
@property (nonatomic, assign) DDPDanmakuMode mode;
/**
 *  Color: 32位整形数的弹幕颜色，算法为 R*256*256 + G*256 + B。
 */
@property (nonatomic, assign) uint32_t color;

/**
 弹幕发送时间戳，单位为毫秒。可以理解为Unix时间戳，但起始点为1970年1月1日7:00:00。
 */
@property (assign, nonatomic) NSTimeInterval timestamp;

/**
 弹幕池，目前此数值为0。
 */
@property (assign, nonatomic) NSUInteger pool;

/**
 用户编号，匿名用户为0，备份弹幕为-1，注册用户为正整数。
 */
@property (assign, nonatomic) NSUInteger userId;

/**
 *  Message: 弹幕内容文字。\r和\n不会作为换行转义符。
 */
@property (nonatomic, strong) NSString* message;

/**
 用户登录令牌，匿名用户需设置为0。
 */
@property (copy, nonatomic) NSString *token;

#pragma mark - 自定义属性
/**
 *  是否被过滤
 */
@property (assign, nonatomic, getter=isFilter) BOOL filter;

@end
