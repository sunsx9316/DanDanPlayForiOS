//
//  DDPPlayerInterfaceView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器UI面板

#import <UIKit/UIKit.h>
#import "DDPPlayerConfigPanelView.h"
#import "DDPPlayerSubTitleIndexView.h"
#import "DDPPlayerSendDanmakuConfigView.h"
#import "DDPPlayerMatchView.h"
#import "DDPControlView.h"

@class DDPPlayerInterfaceView;
@protocol DDPPlayerInterfaceViewDelegate <NSObject>

@optional
- (void)interfaceViewDidTouchSendDanmakuButton;
@end

@class DDPBlurView;
@interface DDPPlayerInterfaceView : UIView
@property (weak, nonatomic) id<DDPPlayerInterfaceViewDelegate> delegate;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UISlider *progressSlider;

@property (strong, nonatomic) UISwitch *danmakuHideSwitch;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *subTitleIndexButton;
@property (strong, nonatomic) UIButton *screenShotButton;
@property (strong, nonatomic) UIActivityIndicatorView *screenShotIndicatorView;

@property (strong, nonatomic) UIView *gestureView;
//从右边画出来的控制面板
@property (strong, nonatomic) DDPPlayerConfigPanelView *configPanelView;
//字幕视图
@property (strong, nonatomic) DDPPlayerSubTitleIndexView *subTitleIndexView;
//左边弹出来的匹配视图
@property (strong, nonatomic) DDPPlayerMatchView *matchNoticeView;
//上次播放时间
@property (strong, nonatomic) DDPPlayerNoticeView *lastTimeNoticeView;
//音量控制视图
@property (strong, nonatomic) DDPControlView *volumeControlView;
//亮度控制视图
@property (strong, nonatomic) DDPControlView *brightnessControlView;
@property (assign, nonatomic, readonly, getter=isShow) BOOL show;


/**
 显示
 */
- (void)showWithAnimate:(BOOL)flag;

/**
 隐藏
 */
- (void)dismissWithAnimate:(BOOL)flag;

- (void)resetTimer;
@end
