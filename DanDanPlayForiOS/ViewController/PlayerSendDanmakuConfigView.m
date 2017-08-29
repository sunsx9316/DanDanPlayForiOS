//
//  PlayerSendDanmakuConfigView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerSendDanmakuConfigView.h"
#import <NKOColorPickerView.h>
#import "JHBlurView.h"

@interface PlayerSendDanmakuConfigView ()
@property (strong, nonatomic) NKOColorPickerView *colorPickerView;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) JHBlurView *contentView;
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *resetButton;
@end

@implementation PlayerSendDanmakuConfigView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0;
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(self).multipliedBy(0.5);
        }];
        
        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_right);
            make.right.mas_offset(0);
            make.centerY.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)show {
    if (self.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 懒加载
- (void)touchSegmentedControl:(UISegmentedControl *)sender {
    JHDanmakuMode _danmakuMode;
    if (sender.selectedSegmentIndex == 1) {
        _danmakuMode = JHDanmakuModeTop;
    }
    else if (sender.selectedSegmentIndex == 2) {
        _danmakuMode = JHDanmakuModeBottom;
    }
    else {
        _danmakuMode = JHDanmakuModeNormal;
    }
    [CacheManager shareCacheManager].sendDanmakuMode = _danmakuMode;
    
    if (self.selectedCallback) {
        self.selectedCallback([CacheManager shareCacheManager].sendDanmakuColor, _danmakuMode);
    }
}

- (void)touchResetButton:(UIButton *)sender {
    [CacheManager shareCacheManager].sendDanmakuColor = [UIColor whiteColor];
    [CacheManager shareCacheManager].sendDanmakuMode = JHDanmakuModeNormal;
    
    self.colorPickerView.color = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.segmentedControl.selectedSegmentIndex = 0;
}


#pragma mark - 懒加载

- (JHBlurView *)contentView {
    if (_contentView == nil) {
        _contentView = [[JHBlurView alloc] init];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 5;
        _contentView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        [_contentView addSubview:self.segmentedControl];
        [_contentView addSubview:self.colorPickerView];
        [_contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(10);
        }];
        
        [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(10);
            make.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.colorPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.segmentedControl.mas_bottom).mas_offset(10);
            make.right.bottom.mas_offset(-10);
            make.left.mas_equalTo(10);
        }];
        
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UISegmentedControl *)segmentedControl {
    if (_segmentedControl == nil) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"普通", @"顶部", @"底部"]];
        [_segmentedControl addTarget:self action:@selector(touchSegmentedControl:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.tintColor = MAIN_COLOR;
        JHDanmakuMode mode = [CacheManager shareCacheManager].sendDanmakuMode;
        if (mode == JHDanmakuModeBottom) {
            _segmentedControl.selectedSegmentIndex = 2;
        }
        else if (mode == JHDanmakuModeTop) {
            _segmentedControl.selectedSegmentIndex = 1;
        }
        else {
            _segmentedControl.selectedSegmentIndex = 0;
        }
        _segmentedControl.tintColor = MAIN_COLOR;
    }
    return _segmentedControl;
}

- (NKOColorPickerView *)colorPickerView {
    if (_colorPickerView == nil) {
        @weakify(self)
        _colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, 0, self.width - 20, self.height - 50) color:nil andDidChangeColorBlock:nil];
        
        _colorPickerView.color = [CacheManager shareCacheManager].sendDanmakuColor;
        [_colorPickerView setDidChangeColorBlock:^(UIColor *color) {
            @strongify(self)
            if (!self) return;
            
            [CacheManager shareCacheManager].sendDanmakuColor = color;
            self.titleLabel.textColor = color;
            
            if (self.selectedCallback) {
                self.selectedCallback(color, [CacheManager shareCacheManager].sendDanmakuMode);
            }
        }];
        
        UIView *aView = [_colorPickerView valueForKey:@"crossHairs"];
        aView.size = CGSizeMake(30, 30);
        aView.layer.cornerRadius = 15;
    }
    return _colorPickerView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        @weakify(self)
        [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            [self dismiss];
        }]];
        _bgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.text = @"_(:3」∠)_ 测试弹幕";
        _titleLabel.textColor = [CacheManager shareCacheManager].sendDanmakuColor;
    }
    return _titleLabel;
}

- (UIButton *)resetButton {
    if (_resetButton == nil) {
        _resetButton = [[UIButton alloc] init];
        [_resetButton setImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(touchResetButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_resetButton];
    }
    return _resetButton;
}

@end
