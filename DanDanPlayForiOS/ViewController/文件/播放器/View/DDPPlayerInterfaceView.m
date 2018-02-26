//
//  DDPPlayerInterfaceView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerInterfaceView.h"
#import "DDPPlayerInterfaceHolderView.h"
#import "DDPBlurView.h"
#import "DDPEdgeButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <YYKeyboardManager.h>

#define AUTO_DISS_MISS_TIME 3.5f

@interface DDPPlayerInterfaceView ()

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) DDPPlayerInterfaceHolderView *interfaceHoldView;
/**
 设置按钮
 */
@property (strong, nonatomic) DDPEdgeButton *settingButton;
@property (strong, nonatomic) UIButton *sendDanmakuButton;
@end

@implementation DDPPlayerInterfaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _show = YES;
        
        [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.interfaceHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.configPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(self.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
            make.left.equalTo(self.mas_right);
        }];
        
        [self.matchNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_offset(-25);
        }];
        
        [self.lastTimeNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.equalTo(self.matchNoticeView.mas_bottom).mas_offset(15);
        }];
        
        @weakify(self)
        self.timer = [NSTimer timerWithTimeInterval:AUTO_DISS_MISS_TIME block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self dismissWithAnimate:YES];
            timer.fireDate = [NSDate distantFuture];
        } repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self resetTimer];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)showWithAnimate:(BOOL)flag {
    if (_show == NO) {
        _show = YES;
        self.topView.transform = CGAffineTransformMakeTranslation(0, -30);
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, 30);
        
        dispatch_block_t action = ^{
            self.interfaceHoldView.alpha = 1;
            self.topView.transform = CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
            [self.viewController setNeedsStatusBarAppearanceUpdate];
            if (@available(iOS 11.0, *)) {
                [self.viewController setNeedsUpdateOfHomeIndicatorAutoHidden];
            }
        };
        
        if (flag) {
            [self animate:action completion:nil];
        }
        else {
            action();
        }
    }
}

- (void)dismissWithAnimate:(BOOL)flag {
    if (_show) {
        _show = NO;
        [self endEditing:YES];
        [self.configPanelView dismissWithAnimate:NO];
        
        dispatch_block_t action = ^{
            self.interfaceHoldView.alpha = 0;
            self.topView.transform = CGAffineTransformMakeTranslation(0, -30);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 30);
            [self.viewController setNeedsStatusBarAppearanceUpdate];
            if (@available(iOS 11.0, *)) {
                [self.viewController setNeedsUpdateOfHomeIndicatorAutoHidden];
            }
            [self layoutIfNeeded];
        };
        
        if (flag) {
            [self animate:action completion:nil];
        }
        else {
            action();
        }
    }
}


#pragma mark - 私有方法
- (void)touchSettingButton:(UIButton *)button {
    if (self.configPanelView.isShow) {
        [self.configPanelView dismissWithAnimate:NO];
    }
    else {
        [self.configPanelView showWithAnimate:NO];
        [self pauserTimer];
    }
    
    [self animate:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)animate:(dispatch_block_t)animateBlock completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:animateBlock completion:completion];
}

- (void)touchSendDanmakuButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(interfaceViewDidTouchSendDanmakuButton)]) {
        [self.delegate interfaceViewDidTouchSendDanmakuButton];
    }
}

- (void)resetTimer {
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:AUTO_DISS_MISS_TIME];
}

- (void)pauserTimer {
    self.timer.fireDate = [NSDate distantFuture];
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] init];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"comment_gradual_gray"] yy_imageByRotate180]];
        bgImgView.alpha = 0.8;
        [_topView addSubview:bgImgView];
        [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(_topView);
        }];
        
        
        [_topView addSubview:self.titleLabel];
        [_topView addSubview:self.backButton];
        [_topView addSubview:self.settingButton];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(20);
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(30 + ddp_isPad() * 20);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right).mas_offset(10);
        }];
        
        [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_offset(-10);
        }];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_gradual_gray"]];
        bgImgView.alpha = 0.8;
        [_bottomView addSubview:bgImgView];
        [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(_bottomView);
        }];
        
        [_bottomView addSubview:self.currentTimeLabel];
        [_bottomView addSubview:self.progressSlider];
        [_bottomView addSubview:self.totalTimeLabel];
        [_bottomView addSubview:self.sendDanmakuButton];
        [_bottomView addSubview:self.danmakuHideSwitch];
        [_bottomView addSubview:self.subTitleIndexButton];
        [_bottomView addSubview:self.screenShotButton];
        [_bottomView addSubview:self.screenShotIndicatorView];
        
        [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.centerY.equalTo(self.progressSlider);
            make.width.mas_equalTo(60);
        }];
        
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.currentTimeLabel.mas_right).mas_offset(10);
            make.top.mas_offset(15);
        }];
        
        [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.progressSlider);
            make.right.mas_offset(-10);
            make.left.equalTo(self.progressSlider.mas_right).mas_offset(10);
            make.width.mas_equalTo(self.currentTimeLabel);
        }];
        
        [self.danmakuHideSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.currentTimeLabel.mas_bottom).mas_offset(15);
            make.right.mas_offset(-10);
            make.bottom.mas_offset(-15);
        }];
        
        [self.sendDanmakuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.danmakuHideSwitch.mas_left).mas_offset(-20);
            make.centerY.equalTo(self.danmakuHideSwitch);
        }];
        
        [self.subTitleIndexButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(20);
            make.centerY.equalTo(self.danmakuHideSwitch);
        }];
        
        [self.screenShotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.subTitleIndexButton);
            make.left.equalTo(self.subTitleIndexButton.mas_right).mas_offset(10);
        }];
        
        [self.screenShotIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.screenShotButton);
        }];
        
    }
    return _bottomView;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"comment_back_item"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)currentTimeLabel {
    if (_currentTimeLabel == nil) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont ddp_smallSizeFont];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (_totalTimeLabel == nil) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont ddp_smallSizeFont];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UISlider *)progressSlider {
    if (_progressSlider == nil) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumTrackTintColor = [UIColor ddp_mainColor];
    }
    return _progressSlider;
}

- (UIButton *)sendDanmakuButton {
    if (_sendDanmakuButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(30, 5);
        _sendDanmakuButton = aButton;
        _sendDanmakuButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_sendDanmakuButton setTitle:@"吐个嘈~" forState:UIControlStateNormal];
        [_sendDanmakuButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
        _sendDanmakuButton.layer.cornerRadius = 6;
        _sendDanmakuButton.layer.masksToBounds = YES;
        _sendDanmakuButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [_sendDanmakuButton addTarget:self action:@selector(touchSendDanmakuButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendDanmakuButton;
}

- (DDPEdgeButton *)settingButton {
    if (_settingButton == nil) {
        _settingButton = [[DDPEdgeButton alloc] init];
        _settingButton.inset = CGSizeMake(20, 6);
        [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
        _settingButton.titleLabel.font = [UIFont ddp_bigSizeFont];
        [_settingButton addTarget:self action:@selector(touchSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        [_settingButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_settingButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _settingButton;
}

- (UISwitch *)danmakuHideSwitch {
    if (_danmakuHideSwitch == nil) {
        _danmakuHideSwitch = [[UISwitch alloc] init];
        _danmakuHideSwitch.onTintColor = [UIColor ddp_mainColor];
        _danmakuHideSwitch.on = YES;
    }
    return _danmakuHideSwitch;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
        _playButton.adjustsImageWhenHighlighted = NO;
        
    }
    return _playButton;
}

- (UIButton *)subTitleIndexButton {
    if (_subTitleIndexButton == nil) {
        DDPEdgeButton *_aButton = [[DDPEdgeButton alloc] init];
        [_aButton setTitle:@"字幕" forState:UIControlStateNormal];
        _aButton.titleLabel.font = [UIFont ddp_bigSizeFont];
        _aButton.inset = CGSizeMake(10, 10);
        _subTitleIndexButton = _aButton;
    }
    return _subTitleIndexButton;
}

- (UIButton *)screenShotButton {
    if (_screenShotButton == nil) {
        DDPEdgeButton *_aButton = [[DDPEdgeButton alloc] init];
        _aButton.inset = CGSizeMake(10, 10);
        _aButton.adjustsImageWhenHighlighted = YES;
        _screenShotButton = _aButton;
        [_screenShotButton setImage:[UIImage imageNamed:@"player_screen_shot"] forState:UIControlStateNormal];
    }
    return _screenShotButton;
}

- (UIActivityIndicatorView *)screenShotIndicatorView {
    if (_screenShotIndicatorView == nil) {
        _screenShotIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _screenShotIndicatorView;
}

- (DDPPlayerConfigPanelView *)configPanelView {
    if (_configPanelView == nil) {
        _configPanelView = [[DDPPlayerConfigPanelView alloc] initWithFrame:CGRectMake(0, 0, self.width * CONFIG_VIEW_WIDTH_RATE, self.height)];
        [self addSubview:_configPanelView];
    }
    return _configPanelView;
}

- (DDPPlayerInterfaceHolderView *)interfaceHoldView {
    if (_interfaceHoldView == nil) {
        _interfaceHoldView = [[DDPPlayerInterfaceHolderView alloc] initWithFrame:self.bounds];
        @weakify(self)
        [_interfaceHoldView setTouchViewCallBack:^{
            @strongify(self)
            if (!self) return;
            
            [self resetTimer];
        }];
        
        [_interfaceHoldView addSubview:self.topView];
        [_interfaceHoldView addSubview:self.bottomView];
        [_interfaceHoldView addSubview:self.playButton];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-20);
            make.bottom.equalTo(self.bottomView.mas_top).mas_offset(-10 - ddp_isPad() * 10);
        }];
        
        [self addSubview:_interfaceHoldView];
    }
    return _interfaceHoldView;
}

- (UIView *)gestureView {
    if (_gestureView == nil) {
        _gestureView = [[UIView alloc] init];
        
        [self addSubview:_gestureView];
    }
    return _gestureView;
}

- (DDPPlayerSubTitleIndexView *)subTitleIndexView {
    if (_subTitleIndexView == nil) {
        _subTitleIndexView = [[DDPPlayerSubTitleIndexView alloc] initWithFrame:self.bounds];
    }
    return _subTitleIndexView;
}

- (DDPPlayerNoticeView *)matchNoticeView {
    if (_matchNoticeView == nil) {
        _matchNoticeView = [[DDPPlayerNoticeView alloc] init];
        [self addSubview:_matchNoticeView];
    }
    return _matchNoticeView;
}

- (DDPPlayerNoticeView *)lastTimeNoticeView {
    if (_lastTimeNoticeView == nil) {
        _lastTimeNoticeView = [[DDPPlayerNoticeView alloc] init];
        _lastTimeNoticeView.autoDismissTime = 5;
        [self addSubview:_lastTimeNoticeView];
    }
    return _lastTimeNoticeView;
}

- (DDPControlView *)volumeControlView {
    if (_volumeControlView == nil) {
        _volumeControlView = [[DDPControlView alloc] initWithImage:[UIImage imageNamed:@"player_volume"]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
        _volumeControlView.progress = mpc.volume;
#pragma clang diagnostic pop
    }
    return _volumeControlView;
}

- (DDPControlView *)brightnessControlView {
    if (_brightnessControlView == nil) {
        _brightnessControlView = [[DDPControlView alloc] initWithImage:[UIImage imageNamed:@"player_brightness"]];
        _brightnessControlView.progress = [UIScreen mainScreen].brightness;
    }
    return _brightnessControlView;
}

@end
