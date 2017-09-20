//
//  JHDMHYSearchConfig.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHDMHYSearchConfig : JHBase

/**
 关键字
 */
@property (copy, nonatomic) NSString *keyword;

/**
 动画类型id
 */
@property (assign, nonatomic) JHEpisodeType episodeType;

/**
 字幕组id
 */
@property (assign, nonatomic) NSUInteger subGroupId;

/**
 链接id
 */
@property (copy, nonatomic) NSString *link;
@end
