//
//  DDPHomeBangumiCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  每天的新番集合

#import "DDPBaseCollection.h"
#import "DDPHomeBangumi.h"

@interface DDPHomeBangumiCollection : DDPBaseCollection<DDPHomeBangumi *>
@property (assign, nonatomic) NSInteger weekDay;
@property (strong, nonatomic, readonly) NSString *weekDayStringValue;
@end
