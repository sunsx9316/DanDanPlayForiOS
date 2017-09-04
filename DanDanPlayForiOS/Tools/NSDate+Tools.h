//
//  NSDate+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/4.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Tools)
/**
 *  获取今天星期
 *
 *  @return 1~6对应星期一~六 0对应星期天
 */
+ (NSInteger)currentWeekDay;
@end
