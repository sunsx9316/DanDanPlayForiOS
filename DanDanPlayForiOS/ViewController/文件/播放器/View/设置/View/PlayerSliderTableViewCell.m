//
//  PlayerSliderTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerSliderTableViewCell.h"
#import "UIFont+Tools.h"

@interface PlayerSliderTableViewCell ()

@end

@implementation PlayerSliderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.currentValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40 + jh_isPad() * 20);
            make.centerY.mas_equalTo(0);
            make.left.mas_offset(0);
        }];
        
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.currentValueLabel.mas_right);
        }];
        
        [self.totalValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.currentValueLabel);
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(0);
            make.left.equalTo(self.slider.mas_right);
        }];
    }
    return self;
}

- (void)touchSlider:(UISlider *)sender {
    sender.value = [[NSString stringWithFormat:@"%.1f", sender.value] floatValue];
    if (self.touchSliderCallback) {
        self.touchSliderCallback(self);
    }
}

- (void)touchSliderUp:(UISlider *)sender {
    if (self.touchSliderUpCallback) {
        self.touchSliderUpCallback(self);
    }
}

- (void)setType:(PlayerSliderTableViewCellType)type {
    _type = type;
    
    if (_type == PlayerSliderTableViewCellTypeFontSize) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.value = [CacheManager shareCacheManager].danmakuFont.pointSize;
        self.slider.minimumValue = 10;
        self.slider.maximumValue = 32;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.slider.value];
    }
    else if (_type == PlayerSliderTableViewCellTypeSpeed) {
        self.slider.value = [CacheManager shareCacheManager].danmakuSpeed;
        self.slider.minimumValue = 0.2;
        self.slider.maximumValue = 3.0;
        self.currentValueLabel.textColor = self.slider.value == self.slider.maximumValue ? [UIColor redColor] : [UIColor whiteColor];
        self.totalValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    }
    else if (_type == PlayerSliderTableViewCellTypeOpacity) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.value = [CacheManager shareCacheManager].danmakuOpacity;
        self.slider.minimumValue = 0.0f;
        self.slider.maximumValue = 1.0f;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    }
    else if (_type == PlayerSliderTableViewCellTypeRate) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.value = 1;
        self.slider.minimumValue = 0.5f;
        self.slider.maximumValue = 2.0f;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    }
}

#pragma mark - 懒加载
- (UISlider *)slider {
    if (_slider == nil) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = INTMAX_MAX;
        [_slider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(touchSliderUp:) forControlEvents:UIControlEventTouchUpInside];
        _slider.minimumTrackTintColor = MAIN_COLOR;
        [self.contentView addSubview:_slider];
    }
    return _slider;
}

- (UILabel *)currentValueLabel {
    if (_currentValueLabel == nil) {
        _currentValueLabel = [[UILabel alloc] init];
        _currentValueLabel.textColor = [UIColor whiteColor];
        _currentValueLabel.font = SMALL_SIZE_FONT;
        _currentValueLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_currentValueLabel];
    }
    return _currentValueLabel;
}

- (UILabel *)totalValueLabel {
    if (_totalValueLabel == nil) {
        _totalValueLabel = [[UILabel alloc] init];
        _totalValueLabel.textColor = [UIColor whiteColor];
        _totalValueLabel.font = SMALL_SIZE_FONT;
        _totalValueLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_totalValueLabel];
    }
    return _totalValueLabel;
}

@end
