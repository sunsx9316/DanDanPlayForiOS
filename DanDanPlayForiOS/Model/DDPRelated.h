//
//  DDPRelated.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPRelated : DDPBase

/**
 弹幕提供者
 */
@property (copy, nonatomic) NSString *provider;

/**
 源地址
 */
@property (copy, nonatomic) NSString *url;

/**
 弹幕偏移量
 */
@property (assign, nonatomic) float shift;
@end
