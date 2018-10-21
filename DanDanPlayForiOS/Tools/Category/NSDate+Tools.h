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


/**
 将字符串格式化为默认时间

 @param dateString 字符串
 @return 时间
 */
+ (NSDate *)dateWithDefaultFormatString:(NSString *)dateString;

/**
 将时间格式化成字符串的形式

 @param date 时间
 @return 字符串
 */
+ (NSString *)attentionTimeStyleWithDate:(NSDate *)date;

/**
 播放历史时间格式

 @param date 时间
 @return 字符串
 */
+ (NSString *)historyTimeStyleWithDate:(NSDate *)date;

/**
 搜索动画形式

 @return 搜索动画形式
 */
- (NSString *)searchAnimeTimeStyle;


/**
 上次观看时间

 @param date 时间
 @return 字符串
 */
+ (NSString *)lastWatchTimeStyleWithDate:(NSDate *)date;
@end
