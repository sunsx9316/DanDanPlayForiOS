//
//  JHRelated.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHRelated : JHBase

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
