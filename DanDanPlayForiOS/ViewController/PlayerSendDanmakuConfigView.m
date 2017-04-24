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
@end

@implementation PlayerSendDanmakuConfigView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.color = [UIColor whiteColor];
        self.titleLabel.textColor = self.color;
        self.danmakuMode = 1;
        self.alpha = 0;
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(20);
            make.bottom.mas_offset(-20);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(self).multipliedBy(0.5);
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
    if (sender.selectedSegmentIndex == 0) {
        _danmakuMode = 1;
    }
    else if (sender.selectedSegmentIndex == 1) {
        _danmakuMode = 5;
    }
    else if (sender.selectedSegmentIndex == 2) {
        _danmakuMode = 4;
    }
}

#pragma mark - 懒加载

- (JHBlurView *)contentView {
    if (_contentView == nil) {
        _contentView = [[JHBlurView alloc] init];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 5;
        _contentView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
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
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.tintColor = MAIN_COLOR;
    }
    return _segmentedControl;
}

- (NKOColorPickerView *)colorPickerView {
    if (_colorPickerView == nil) {
        @weakify(self)
        _colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, 0, self.width - 20, self.height - 50) color:self.color andDidChangeColorBlock:^(UIColor *color){
            
        }];
        
        _colorPickerView.color = self.color;
        [_colorPickerView setDidChangeColorBlock:^(UIColor *color) {
            @strongify(self)
            if (!self) return;
            
            self.color = color;
            self.titleLabel.textColor = color;
        }];
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
        _bgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.text = @"_(:3」∠)_ 测试弹幕";
        
    }
    return _titleLabel;
}

@end
