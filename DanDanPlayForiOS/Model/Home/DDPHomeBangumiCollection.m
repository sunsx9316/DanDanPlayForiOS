//
//  DDPHomeBangumiCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomeBangumiCollection.h"

@implementation DDPHomeBangumiCollection
{
    NSString *_weekDayStringValue;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"weekDay" : @"DayOfWeek",
             @"collection" : @"Bangumi"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"collection" : [DDPHomeBangumi class]};
}

- (NSString *)weekDayStringValue {
    
    if (_weekDayStringValue) return _weekDayStringValue;
    
    switch (_weekDay) {
        case 0:
            _weekDayStringValue =  @"星期天";
            break;
        case 1:
            _weekDayStringValue = @"星期一";
            break;
        case 2:
            _weekDayStringValue = @"星期二";
            break;
        case 3:
            _weekDayStringValue = @"星期三";
            break;
        case 4:
            _weekDayStringValue = @"星期四";
            break;
        case 5:
            _weekDayStringValue = @"星期五";
            break;
        case 6:
            _weekDayStringValue = @"星期六";
            break;
    }
    
    if (!_weekDayStringValue) {
        _weekDayStringValue = @"";
    }
    
    return _weekDayStringValue;
}

@end
