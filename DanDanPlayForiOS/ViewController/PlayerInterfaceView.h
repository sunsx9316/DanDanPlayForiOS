//
//  PlayerInterfaceView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器控制面板

#import <UIKit/UIKit.h>
#import "JHEdgeButton.h"

@class JHBlurView;
@interface PlayerInterfaceView : UIView
@property (strong, nonatomic) JHBlurView *topView;
@property (strong, nonatomic) JHBlurView *bottomView;

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UITextField *sendDanmakuTextField;
@property (strong, nonatomic) JHEdgeButton *sendDanmakuConfigButton;
@property (strong, nonatomic) JHEdgeButton *settingButton;
@property (strong, nonatomic) UISwitch *danmakuHideSwitch;
@property (strong, nonatomic) UIButton *playButton;
@end
