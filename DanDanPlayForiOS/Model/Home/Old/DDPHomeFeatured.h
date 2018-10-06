//
//  DDPHomeFeatured.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  首页今日推荐新番

#import "DDPBase.h"

@interface DDPHomeFeatured : DDPBase
/**
 *  name 标题
 link 跳转链接
 desc 介绍
 */

@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *link;
@end
