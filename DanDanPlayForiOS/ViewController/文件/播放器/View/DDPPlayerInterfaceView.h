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
@property (strong, nonatomic) DDPPlayerConfigPanelView *configPanelView;
@property (strong, nonatomic) DDPPlayerSubTitleIndexView *subTitleIndexView;
@property (strong, nonatomic) DDPPlayerMatchView *matchNoticeView;
@property (strong, nonatomic) DDPPlayerNoticeView *lastTimeNoticeView;
@property (strong, nonatomic) DDPControlView *volumeControlView;
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
