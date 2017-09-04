//
//  NSDate+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/4.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "NSDate+Tools.h"

@implementation NSDate (Tools)
+ (NSInteger)currentWeekDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [comps weekday] - 1;
}
@end
