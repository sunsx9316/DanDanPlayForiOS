//
//  DDPBiliBiliSearchVideo.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPBiliBiliSearchVideo : DDPBase
/*
 identity -> aid
 name -> title
 desc -> description
 */


/**
 图片
 */
@property (strong, nonatomic) NSURL *pic;

/**
 类型
 */
@property (copy, nonatomic) NSString *typeName;
/**
 发布时间
 */
@property (assign, nonatomic) UInt64 publicTime;

/**
 时长
 */
@property (copy, nonatomic) NSString *duration;
 
@end
