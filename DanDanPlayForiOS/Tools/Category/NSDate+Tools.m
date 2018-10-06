//
//  NSDate+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/4.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "NSDate+Tools.h"
#define DEFAULT_TIME_STYLE @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
#define DEFAULT_TIME_SHORT_STYLE @"yyyy-MM-dd'T'HH:mm:ss.SS"
#define YEAR_MONTH_HOUR_MINUTE_DAY_TIME_STYLE @"yyyy/M/d HH:mm"
#define YEAR_MONTH_HOUR_MINUTE_DAY_TIME_LONG_STYLE @"yyyy/MM/dd HH:mm"
#define HISTORY_YEAR_MONTH_HOUR_MINUTE_DAY_TIME_LONG_STYLE @"yyyy-MM-dd HH:mm:ss"
#define LAST_WATCH_HOUR_MINUTE_DAY_TIME_LONG_STYLE @"HH:mm"

@implementation NSDate (Tools)
+ (NSDateFormatter *)shareDateFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

+ (NSInteger)currentWeekDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [comps weekday] - 1;
}

+ (NSDate *)dateWithDefaultFormatString:(NSString *)dateString {
    if (dateString.length == 0) return nil;
    NSDateFormatter *dateFormatter = [self shareDateFormatter];
    dateFormatter.dateFormat = DEFAULT_TIME_SHORT_STYLE;
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSString *)attentionTimeStyleWithDate:(NSDate *)date {
    if (date == nil) return nil;
    
    NSDateFormatter *dateFormatter = [self shareDateFormatter];
    dateFormatter.dateFormat = YEAR_MONTH_HOUR_MINUTE_DAY_TIME_STYLE;
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)historyTimeStyleWithDate:(NSDate *)date {
    if (date == nil) return nil;
    
    NSDateFormatter *dateFormatter = [self shareDateFormatter];
    dateFormatter.dateFormat = HISTORY_YEAR_MONTH_HOUR_MINUTE_DAY_TIME_LONG_STYLE;
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)lastWatchTimeStyleWithDate:(NSDate *)date {
    if (date == nil) return nil;
    
    if (date.isToday) {
        NSDateFormatter *dateFormatter = [self shareDateFormatter];
        dateFormatter.dateFormat = LAST_WATCH_HOUR_MINUTE_DAY_TIME_LONG_STYLE;
        return [NSString stringWithFormat:@"今天 %@", [dateFormatter stringFromDate:date]];
    }
    else if (date.isYesterday) {
        NSDateFormatter *dateFormatter = [self shareDateFormatter];
        dateFormatter.dateFormat = LAST_WATCH_HOUR_MINUTE_DAY_TIME_LONG_STYLE;
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:date]];
    }
    
    NSDateFormatter *dateFormatter = [self shareDateFormatter];
    dateFormatter.dateFormat = HISTORY_YEAR_MONTH_HOUR_MINUTE_DAY_TIME_LONG_STYLE;
    return [dateFormatter stringFromDate:date];
}

- (NSString *)searchAnimeTimeStyle {
    NSDateFormatter *dateFormatter = [NSDate shareDateFormatter];
    dateFormatter.dateFormat = @"yyyy年MM月";
    return [dateFormatter stringFromDate:self];
}

@end
