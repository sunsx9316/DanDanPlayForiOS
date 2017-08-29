//
//  JHBaseDanmaku+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHDanmakuRender.h"

@interface JHBaseDanmaku (Tools)

/**
 是否过滤
 */
@property (assign, nonatomic) BOOL filter;

/**
 由用户发送时需要指定一个id
 */
@property (assign, nonatomic) NSUInteger sendByUserId;
@end
