//
//  JHFilter.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHFilter : JHBase

/*
  name 屏蔽规则名称
 */

/**
 是否为正则表达式
 */
@property (assign, nonatomic) BOOL isRegex;

/**
 内容
 */
@property (copy, nonatomic) NSString *content;

@property (assign, nonatomic) BOOL enable;
@end
