//
//  JHSetting.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

typedef NS_ENUM(NSUInteger, JHSettingItemType) {
    JHSettingItemTypeDanmakuFont,
    JHSettingItemTypeSwitch,
    JHSettingItemTypeLeftRight,
    JHSettingItemTypeFilter,
};

@interface JHSettingItem : JHBase
@property (assign, nonatomic) JHSettingItemType type;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *detail;

@property (copy, nonatomic) BOOL(^switchStatusCallBack)();
@property (copy, nonatomic) void(^switchStatusChangeCallBack)();
@property (copy, nonatomic) NSString *(^detailTextCallBack)();
@end

@interface JHSetting : JHBase
@property (strong, nonatomic) NSMutableArray <JHSettingItem *>*items;
@property (copy, nonatomic) NSString *title;
@end
