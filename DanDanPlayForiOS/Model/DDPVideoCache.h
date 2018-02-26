//
//  DDPVideoCache.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPVideoCache : DDPBase

/**
 哈希值

 */
@property (copy, nonatomic) NSString *md5;

/**
 上次播放时间
 */
@property (assign, nonatomic) NSInteger lastPlayTime;
 
@end
