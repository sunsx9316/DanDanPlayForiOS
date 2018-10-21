//
//  DDPPlayerConfigPanelViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class DDPPlayerConfigPanelViewController;
@protocol DDPPlayerConfigPanelViewControllerDelegate <NSObject>
@optional

/**
 选择视频
 
 @param view view
 @param model 视频
 */
- (void)playerConfigPanelViewController:(DDPPlayerConfigPanelViewController * _Nullable)viewController didSelectedModel:(DDPVideoModel * _Nullable)model;

/**
 弹幕偏移时间
 
 @param view view
 @param value 偏移时间
 */
- (void)playerConfigPanelViewController:(DDPPlayerConfigPanelViewController * _Nullable)viewController didTouchStepper:(CGFloat)value;

/**
 加载本地弹幕
 */
- (void)playerConfigPanelViewControllerDidTouchSelectedDanmakuCell;

/**
 手动匹配
 */
- (void)playerConfigPanelViewControllerDidTouchMatchCell;

/**
 屏蔽弹幕列表
 */
- (void)playerConfigPanelViewControllerDidTouchFilterCell;

/**
 选择其他设置
 */
- (void)playerConfigPanelViewControllerDidTouchOtherSettingCell;
@end

@interface DDPPlayerConfigPanelViewController : DDPBaseViewController
@property (weak, nonatomic) id<DDPPlayerConfigPanelViewControllerDelegate>  _Nullable delegate;

@property (copy, nonatomic) void(^touchBgViewCallBack)(void);
@end

NS_ASSUME_NONNULL_END
