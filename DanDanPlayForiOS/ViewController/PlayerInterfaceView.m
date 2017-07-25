//
//  PlayerInterfaceView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerInterfaceView.h"
#import "PlayerInterfaceHolderView.h"
#import "JHBlurView.h"
#import "JHEdgeButton.h"

@interface PlayerInterfaceView ()

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) PlayerInterfaceHolderView *interfaceHoldView;
/**
 弹幕开关
 */
@property (strong, nonatomic) UILabel *switchLabel;

/**
 设置按钮
 */
@property (strong, nonatomic) JHEdgeButton *settingButton;
@property (strong, nonatomic) JHEdgeButton *sendDanmakuConfigButton;
@end

@implementation PlayerInterfaceView

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
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self dismissWithAnimate:YES];
        } repeats:NO];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)expandDanmakuTextField {
    [self.sendDanmakuTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(15);
        make.height.mas_equalTo(35 + jh_isPad() * 10);
        make.left.mas_offset(20);
    }];
}

- (void)packUpDanmakuTextField {
    [self.sendDanmakuTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(15);
        make.height.mas_equalTo(35 + jh_isPad() * 10);
        make.width.mas_equalTo(70);
    }];
    
    self.sendDanmakuTextField.text = nil;
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
    }
    
    [self animate:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)touchSendDanmakuConfigButton:(UIButton *)sender {
    [self.sendDanmakuConfigView show];
    [self endEditing:YES];
}

- (void)animate:(dispatch_block_t)animateBlock completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:animateBlock completion:completion];
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
            make.height.mas_equalTo(30 + jh_isPad() * 20);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right).mas_offset(10);
            //            make.right.mas_offset(-10);
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
        [_bottomView addSubview:self.sendDanmakuTextField];
        [_bottomView addSubview:self.danmakuHideSwitch];
        [_bottomView addSubview:self.switchLabel];
        [_bottomView addSubview:self.subTitleIndexButton];
        
        [self.sendDanmakuTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(15);
            make.height.mas_equalTo(35 + jh_isPad() * 10);
            float width = [self.sendDanmakuTextField.attributedPlaceholder boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
            make.width.mas_equalTo(width + 15);
        }];
        
        [self.switchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-10);
            make.centerY.equalTo(self.sendDanmakuTextField);
        }];
        
        [self.subTitleIndexButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sendDanmakuTextField.mas_right).mas_offset(10);
            make.centerY.equalTo(self.sendDanmakuTextField);
        }];
        
        [self.danmakuHideSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.switchLabel.mas_left).mas_offset(-5);
            make.left.equalTo(self.subTitleIndexButton.mas_right).mas_offset(10);
            make.centerY.equalTo(self.sendDanmakuTextField);
        }];
        
        [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.centerY.equalTo(self.progressSlider);
            make.width.mas_equalTo(60);
        }];
        
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.currentTimeLabel.mas_right).mas_offset(10);
            make.top.equalTo(self.sendDanmakuTextField.mas_bottom).mas_offset(15);
            make.bottom.mas_offset(-10);
        }];
        
        [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.progressSlider);
            make.right.mas_offset(-10);
            make.left.equalTo(self.progressSlider.mas_right).mas_offset(10);
            make.width.mas_equalTo(self.currentTimeLabel);
        }];
        
    }
    return _bottomView;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)currentTimeLabel {
    if (_currentTimeLabel == nil) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = SMALL_SIZE_FONT;
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (_totalTimeLabel == nil) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = SMALL_SIZE_FONT;
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UISlider *)progressSlider {
    if (_progressSlider == nil) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumTrackTintColor = MAIN_COLOR;
    }
    return _progressSlider;
}

- (UITextField *)sendDanmakuTextField {
    if (_sendDanmakuTextField == nil) {
        _sendDanmakuTextField = [[UITextField alloc] init];
        _sendDanmakuTextField.borderStyle = UITextBorderStyleRoundedRect;
        _sendDanmakuTextField.returnKeyType = UIReturnKeySend;
        _sendDanmakuTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"吐个嘈~" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        _sendDanmakuTextField.rightView = self.sendDanmakuConfigButton;
        _sendDanmakuTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    }
    return _sendDanmakuTextField;
}

- (JHEdgeButton *)settingButton {
    if (_settingButton == nil) {
        _settingButton = [[JHEdgeButton alloc] init];
        _settingButton.inset = CGSizeMake(20, 6);
        [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
        _settingButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_settingButton addTarget:self action:@selector(touchSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        [_settingButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_settingButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _settingButton;
}

- (UISwitch *)danmakuHideSwitch {
    if (_danmakuHideSwitch == nil) {
        _danmakuHideSwitch = [[UISwitch alloc] init];
        _danmakuHideSwitch.onTintColor = MAIN_COLOR;
        _danmakuHideSwitch.on = YES;
        _danmakuHideSwitch.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }
    return _danmakuHideSwitch;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"play_pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"play_play"] forState:UIControlStateSelected];
        _playButton.adjustsImageWhenHighlighted = NO;
        
    }
    return _playButton;
}

- (UILabel *)switchLabel {
    if (_switchLabel == nil) {
        _switchLabel = [[UILabel alloc] init];
        _switchLabel.font = SMALL_SIZE_FONT;
        _switchLabel.textColor = [UIColor whiteColor];
        _switchLabel.text = @"弹幕";
        [_switchLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_switchLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _switchLabel;
}

- (JHEdgeButton *)sendDanmakuConfigButton {
    if (_sendDanmakuConfigButton == nil) {
        _sendDanmakuConfigButton = [[JHEdgeButton alloc] init];
        [_sendDanmakuConfigButton setImage:[UIImage imageNamed:@"player_danmaku_color"] forState:UIControlStateNormal];
        _sendDanmakuConfigButton.inset = CGSizeMake(10, 8);
        [_sendDanmakuConfigButton sizeToFit];
        [_sendDanmakuConfigButton addTarget:self action:@selector(touchSendDanmakuConfigButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendDanmakuConfigButton;
}

- (UIButton *)subTitleIndexButton {
    if (_subTitleIndexButton == nil) {
        JHEdgeButton *_aButton = [[JHEdgeButton alloc] init];
        [_aButton setTitle:@"字幕" forState:UIControlStateNormal];
        _aButton.titleLabel.font = NORMAL_SIZE_FONT;
        _aButton.inset = CGSizeMake(10, 8);
        _subTitleIndexButton = _aButton;
    }
    return _subTitleIndexButton;
}

- (PlayerConfigPanelView *)configPanelView {
    if (_configPanelView == nil) {
        _configPanelView = [[PlayerConfigPanelView alloc] initWithFrame:CGRectMake(0, 0, self.width * CONFIG_VIEW_WIDTH_RATE, self.height)];
        [self addSubview:_configPanelView];
    }
    return _configPanelView;
}

- (PlayerInterfaceHolderView *)interfaceHoldView {
    if (_interfaceHoldView == nil) {
        _interfaceHoldView = [[PlayerInterfaceHolderView alloc] initWithFrame:self.bounds];
        
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
            make.bottom.equalTo(self.bottomView.mas_top).mas_offset(-10 - jh_isPad() * 10);
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

- (PlayerSendDanmakuConfigView *)sendDanmakuConfigView {
    if (_sendDanmakuConfigView == nil) {
        _sendDanmakuConfigView = [[PlayerSendDanmakuConfigView alloc] initWithFrame:self.bounds];
    }
    return _sendDanmakuConfigView;
}

- (PlayerSubTitleIndexView *)subTitleIndexView {
    if (_subTitleIndexView == nil) {
        _subTitleIndexView = [[PlayerSubTitleIndexView alloc] initWithFrame:self.bounds];
    }
    return _subTitleIndexView;
}

- (PlayerNoticeView *)matchNoticeView {
    if (_matchNoticeView == nil) {
        _matchNoticeView = [[PlayerNoticeView alloc] init];
        [self addSubview:_matchNoticeView];
    }
    return _matchNoticeView;
}

- (PlayerNoticeView *)lastTimeNoticeView {
    if (_lastTimeNoticeView == nil) {
        _lastTimeNoticeView = [[PlayerNoticeView alloc] init];
        _lastTimeNoticeView.autoDismissTime = 3.2;
        [self addSubview:_lastTimeNoticeView];
    }
    return _lastTimeNoticeView;
}

@end
