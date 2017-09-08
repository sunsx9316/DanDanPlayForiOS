//
//  JHDMHYParse.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHDMHYParse : JHBase
/*
 identity -> TeamId
 */

@property (strong, nonatomic) NSArray <NSString *>*keywords;

/**
 拼接的关键字
 */
@property (copy, nonatomic) NSString *keyword;
@end
