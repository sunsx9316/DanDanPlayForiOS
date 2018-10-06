//
//  DDPDMHYSearchConfig.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPDMHYSearchConfig : DDPBase

/**
 关键字
 */
@property (copy, nonatomic) NSString *keyword;

/**
 动画类型id 完整列表 ->  res.acplay.net/type
 */
@property (assign, nonatomic) NSInteger episodeType;

/**
 字幕组id
 */
@property (assign, nonatomic) NSUInteger subGroupId;

/**
 链接id
 */
//@property (copy, nonatomic) NSString *link;
@end
