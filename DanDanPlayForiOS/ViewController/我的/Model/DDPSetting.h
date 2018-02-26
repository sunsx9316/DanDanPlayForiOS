//
//  DDPSetting.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

typedef NS_ENUM(NSUInteger, DDPSettingItemType) {
    DDPSettingItemTypeDanmakuFont,
    DDPSettingItemTypeSwitch,
    DDPSettingItemTypeLeftRight,
    DDPSettingItemTypeFilter,
};

@interface DDPSettingItem : DDPBase
@property (assign, nonatomic) DDPSettingItemType type;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *detail;

@property (copy, nonatomic) BOOL(^switchStatusCallBack)(void);
@property (copy, nonatomic) void(^switchStatusChangeCallBack)(void);
@property (copy, nonatomic) NSString *(^detailTextCallBack)(void);
@end

@interface DDPSetting : DDPBase
@property (strong, nonatomic) NSMutableArray <DDPSettingItem *>*items;
@property (copy, nonatomic) NSString *title;
@end
