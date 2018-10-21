//
//  DDPPlayerDanmakuControlViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPPlayerDanmakuControlViewController : DDPBaseViewController

/**
 弹幕偏移时间
 */
@property (copy, nonatomic) void(^_Nullable touchStepperCallBack)(CGFloat value);

/**
 加载本地弹幕
 */
@property (copy, nonatomic) void(^_Nullable touchSelectedDanmakuCellCallBack)(void);

/**
 手动匹配视频
 */
@property (copy, nonatomic) void(^_Nullable touchMatchVideoCellCallBack)(void);

/**
 点击筛选弹幕功能
 */
@property (copy, nonatomic) void(^_Nullable touchFilterDanmakuCellCallBack)(void);

/**
 点击其他设置
 */
@property (copy, nonatomic) void(^_Nullable touchOtherSettingCellCallBack)(void);

@end

NS_ASSUME_NONNULL_END
