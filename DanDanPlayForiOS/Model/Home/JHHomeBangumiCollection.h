//
//  JHHomeBangumiCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  每天的新番集合

#import "JHBaseCollection.h"
#import "JHHomeBangumi.h"

@interface JHHomeBangumiCollection : JHBaseCollection
@property (assign, nonatomic) NSInteger weekDay;
@property (strong, nonatomic, readonly) NSString *weekDayStringValue;
@end
