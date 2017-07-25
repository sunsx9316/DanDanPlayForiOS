//
//  PlayerInterfaceView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器UI面板

#import <UIKit/UIKit.h>
#import "PlayerConfigPanelView.h"
#import "PlayerSubTitleIndexView.h"
#import "PlayerSendDanmakuConfigView.h"
#import "PlayerNoticeView.h"

@class JHBlurView;
@interface PlayerInterfaceView : UIView
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UITextField *sendDanmakuTextField;
@property (strong, nonatomic) UISwitch *danmakuHideSwitch;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *subTitleIndexButton;

@property (strong, nonatomic) UIView *gestureView;
@property (strong, nonatomic) PlayerConfigPanelView *configPanelView;
@property (strong, nonatomic) PlayerSendDanmakuConfigView *sendDanmakuConfigView;
@property (strong, nonatomic) PlayerSubTitleIndexView *subTitleIndexView;
@property (strong, nonatomic) PlayerNoticeView *matchNoticeView;
@property (strong, nonatomic) PlayerNoticeView *lastTimeNoticeView;
@property (assign, nonatomic, readonly, getter=isShow) BOOL show;

/**
 展开发送弹幕输入框
 */
- (void)expandDanmakuTextField;

/**
 收起发送弹幕输入框
 */
- (void)packUpDanmakuTextField;

/**
 显示
 */
- (void)showWithAnimate:(BOOL)flag;

/**
 隐藏
 */
- (void)dismissWithAnimate:(BOOL)flag;
@end
