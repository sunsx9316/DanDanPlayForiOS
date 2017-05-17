//
//  PlayerInterfaceView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerInterfaceView.h"
#import "JHBlurView.h"

@interface PlayerInterfaceView ()
@property (strong, nonatomic) UILabel *switchLabel;
@end

@implementation PlayerInterfaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (CGRectContainsPoint(self.topView.frame, point) || CGRectContainsPoint(self.bottomView.frame, point) || CGRectContainsPoint(self.playButton.frame, point)) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

#pragma mark - 懒加载
- (JHBlurView *)topView {
    if (_topView == nil) {
        _topView = [[JHBlurView alloc] init];
        
        [_topView addSubview:self.titleLabel];
        [_topView addSubview:self.backButton];
        [_topView addSubview:self.settingButton];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(30 + jh_isPad() * 20);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.backButton.mas_right).mas_offset(10);
            //            make.right.mas_offset(-10);
        }];
        
        [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_offset(-10);
        }];
        
        [self addSubview:_topView];
    }
    return _topView;
}

- (JHBlurView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[JHBlurView alloc] init];
        
        [_bottomView addSubview:self.currentTimeLabel];
        [_bottomView addSubview:self.progressSlider];
        [_bottomView addSubview:self.totalTimeLabel];
        [_bottomView addSubview:self.sendDanmakuTextField];
        [_bottomView addSubview:self.danmakuHideSwitch];
        [_bottomView addSubview:self.switchLabel];
        [_bottomView addSubview:self.sendDanmakuConfigButton];
        [_bottomView addSubview:self.subTitleIndexButton];
        
        [self.sendDanmakuTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(15);
            make.left.mas_offset(20);
            make.height.mas_equalTo(35 + jh_isPad() * 10);
        }];
        
        [self.sendDanmakuConfigButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.sendDanmakuTextField);
            make.left.equalTo(self.sendDanmakuTextField.mas_right).mas_offset(10);
        }];
        
        [self.switchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-10);
            make.centerY.equalTo(self.sendDanmakuTextField);
        }];
        
        [self.subTitleIndexButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sendDanmakuConfigButton.mas_right).mas_offset(10);
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
        
        [self addSubview:_bottomView];
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
//        _sendDanmakuTextField.textColor = [UIColor whiteColor];
    }
    return _sendDanmakuTextField;
}

- (JHEdgeButton *)settingButton {
    if (_settingButton == nil) {
        _settingButton = [[JHEdgeButton alloc] init];
        _settingButton.inset = CGSizeMake(20, 6);
        [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
        _settingButton.titleLabel.font = NORMAL_SIZE_FONT;
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
        [self addSubview:_playButton];
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
    }
    return _sendDanmakuConfigButton;
}

- (JHEdgeButton *)subTitleIndexButton {
    if (_subTitleIndexButton == nil) {
        _subTitleIndexButton = [[JHEdgeButton alloc] init];
        [_subTitleIndexButton setTitle:@"字幕轨道" forState:UIControlStateNormal];
        _settingButton.titleLabel.font = NORMAL_SIZE_FONT;
        _subTitleIndexButton.inset = CGSizeMake(10, 8);
    }
    return _subTitleIndexButton;
}

@end
