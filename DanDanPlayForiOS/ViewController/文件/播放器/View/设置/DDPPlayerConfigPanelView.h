//
//  DDPPlayerConfigPanelView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器右边的控制面板

#import "DDPBlurView.h"
#define CONFIG_VIEW_WIDTH_RATE 0.5

@class DDPPlayerConfigPanelView;
@protocol DDPPlayerConfigPanelViewDelegate <NSObject>
@optional

/**
 选择视频

 @param view view
 @param model 视频
 */
- (void)playerConfigPanelView:(DDPPlayerConfigPanelView *)view didSelectedModel:(DDPVideoModel *)model;

/**
 弹幕偏移时间

 @param view view
 @param value 偏移时间
 */
- (void)playerConfigPanelView:(DDPPlayerConfigPanelView *)view didTouchStepper:(CGFloat)value;

/**
 加载本地弹幕
 */
- (void)playerConfigPanelViewDidTouchSelectedDanmakuCell;

/**
 手动匹配
 */
- (void)playerConfigPanelViewDidTouchMatchCell;

/**
 屏蔽弹幕列表
 */
- (void)playerConfigPanelViewDidTouchFilterCell;

/**
 选择其他设置
 */
- (void)playerConfigPanelViewDidTouchOtherSettingCell;
@end

@interface DDPPlayerConfigPanelView : DDPBlurView
@property (weak, nonatomic) id<DDPPlayerConfigPanelViewDelegate> delegate;
@property (assign, nonatomic, getter=isShow) BOOL show;
- (void)showWithAnimate:(BOOL)flag;
- (void)dismissWithAnimate:(BOOL)flag;
@end
