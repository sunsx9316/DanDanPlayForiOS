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

@class PlayerInterfaceView;
@protocol PlayerInterfaceViewDelegate <NSObject>

@optional
- (void)interfaceViewDidTouchSendDanmakuButton;
@end

@class JHBlurView;
@interface PlayerInterfaceView : UIView
@property (weak, nonatomic) id<PlayerInterfaceViewDelegate> delegate;

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

@property (strong, nonatomic) UIView *gestureView;
@property (strong, nonatomic) PlayerConfigPanelView *configPanelView;
@property (strong, nonatomic) PlayerSubTitleIndexView *subTitleIndexView;
@property (strong, nonatomic) PlayerNoticeView *matchNoticeView;
@property (strong, nonatomic) PlayerNoticeView *lastTimeNoticeView;
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
