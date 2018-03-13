//
//  DDPBiliBiliSearchBangumi.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPBiliBiliSearchBangumi : DDPBase
/*
 identity -> bangumi_id
 name -> title
 desc -> evaluate
 */


/**
 封面
 */
@property (strong, nonatomic) NSURL *cover;

/**
 cv
 */
@property (copy, nonatomic) NSString *cv;


/**
 风格
 */
@property (copy, nonatomic) NSString *styles;

/**
 弹幕数
 */
@property (assign, nonatomic) NSUInteger danmakuCount;

/**
 是否完结
 */
@property (assign, nonatomic) BOOL isFinish;

/**
 总集数
 */
@property (assign, nonatomic) NSUInteger totalCount;

/**
 发布时间
 */
@property (assign, nonatomic) UInt64 publicTime;
 
@end
