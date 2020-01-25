//
//  DDPPlayerSliderTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerSliderTableViewCell.h"
#import "UIFont+Tools.h"

@interface DDPPlayerSliderTableViewCell ()

@end

@implementation DDPPlayerSliderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.currentValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40 + ddp_isPad() * 20);
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
    //限制slider值
    if (_type == DDPPlayerSliderTableViewCellTypeDanmakuLimit || _type == DDPPlayerSliderTableViewCellTypeFontSize) {
        sender.value = (NSInteger)sender.value;
    }
    else {
        sender.value = [[NSString stringWithFormat:@"%.1f", sender.value] floatValue];
    }
    
    switch (_type) {
        case DDPPlayerSliderTableViewCellTypeFontSize:
        {
            NSInteger value = sender.value;
            UIFont *danmakuFont = [DDPCacheManager shareCacheManager].danmakuFont;
            UIFont *tempFont = nil;
            if (danmakuFont.isSystemFont) {
                tempFont = [UIFont systemFontOfSize:value];
            } else {
                tempFont = [danmakuFont fontWithSize:value];
            }
            tempFont.isSystemFont = danmakuFont.isSystemFont;
            [DDPCacheManager shareCacheManager].danmakuFont = tempFont;
            self.currentValueLabel.text = [NSString stringWithFormat:@"%ld", (long)value];
        }
            break;
        case DDPPlayerSliderTableViewCellTypeDanmakuLimit:
        {
            NSInteger value = sender.value;
            
            if (value == sender.maximumValue) {
                self.currentValueLabel.text = @"∞";
            }
            else {
                self.currentValueLabel.text = [NSString stringWithFormat:@"%ld", (long)value];
            }
        }
            break;
        case DDPPlayerSliderTableViewCellTypeSpeed:
        {
            self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
            self.currentValueLabel.textColor = sender.value == sender.maximumValue ? [UIColor redColor] : [UIColor whiteColor];
            [DDPCacheManager shareCacheManager].danmakuSpeed = sender.value;
        }
            break;
        case DDPPlayerSliderTableViewCellTypeOpacity:
        {
            [DDPCacheManager shareCacheManager].danmakuOpacity = sender.value;
            self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
        }
            break;
        case DDPPlayerSliderTableViewCellTypeRate:
        {
            self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
        }
            break;
            
        default:
            break;
    }
    
    if (self.touchSliderCallback) {
        self.touchSliderCallback(self);
    }
}

- (void)touchSliderUp:(UISlider *)sender {
    if (_type == DDPPlayerSliderTableViewCellTypeRate) {
        [DDPCacheManager shareCacheManager].playerSpeed = sender.value;
    }
    else if (_type == DDPPlayerSliderTableViewCellTypeDanmakuLimit) {
        NSInteger value = sender.value;
        if (value == sender.maximumValue) {
            [DDPCacheManager shareCacheManager].danmakuLimitCount = 0;
        }
        else {
            [DDPCacheManager shareCacheManager].danmakuLimitCount = value;
        }
    }
    
    if (self.touchSliderUpCallback) {
        self.touchSliderUpCallback(self);
    }
}

- (void)setType:(DDPPlayerSliderTableViewCellType)type {
    _type = type;
    
    if (_type == DDPPlayerSliderTableViewCellTypeFontSize) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.value = [DDPCacheManager shareCacheManager].danmakuFont.pointSize;
        self.slider.minimumValue = 10;
        self.slider.maximumValue = 32;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.slider.value];
    }
    else if (_type == DDPPlayerSliderTableViewCellTypeSpeed) {
        self.slider.value = [DDPCacheManager shareCacheManager].danmakuSpeed;
        self.slider.minimumValue = 0.2;
        self.slider.maximumValue = 3.0;
        self.currentValueLabel.textColor = self.slider.value == self.slider.maximumValue ? [UIColor redColor] : [UIColor whiteColor];
        self.totalValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    }
    else if (_type == DDPPlayerSliderTableViewCellTypeOpacity) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.value = [DDPCacheManager shareCacheManager].danmakuOpacity;
        self.slider.minimumValue = 0.0f;
        self.slider.maximumValue = 1.0f;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    }
    else if (_type == DDPPlayerSliderTableViewCellTypeRate) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.value = [DDPCacheManager shareCacheManager].playerSpeed;
        self.slider.minimumValue = 0.5f;
        self.slider.maximumValue = 2.0f;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.maximumValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    }
    else if (_type == DDPPlayerSliderTableViewCellTypeDanmakuLimit) {
        self.currentValueLabel.textColor = [UIColor whiteColor];
        self.slider.minimumValue = 1;
        self.slider.maximumValue = 100;
        NSInteger danmakuLimitCount = [DDPCacheManager shareCacheManager].danmakuLimitCount;
        self.slider.value = danmakuLimitCount == 0 ? self.slider.maximumValue : danmakuLimitCount;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.slider.maximumValue];
        
        if (self.slider.value == self.slider.maximumValue) {
            self.currentValueLabel.text = @"∞";
        }
        else {
            self.currentValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.slider.value];
        }
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
        _slider.minimumTrackTintColor = [UIColor ddp_mainColor];
        [self.contentView addSubview:_slider];
    }
    return _slider;
}

- (UILabel *)currentValueLabel {
    if (_currentValueLabel == nil) {
        _currentValueLabel = [[UILabel alloc] init];
        _currentValueLabel.textColor = [UIColor whiteColor];
        _currentValueLabel.font = [UIFont ddp_smallSizeFont];
        _currentValueLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_currentValueLabel];
    }
    return _currentValueLabel;
}

- (UILabel *)totalValueLabel {
    if (_totalValueLabel == nil) {
        _totalValueLabel = [[UILabel alloc] init];
        _totalValueLabel.textColor = [UIColor whiteColor];
        _totalValueLabel.font = [UIFont ddp_smallSizeFont];
        _totalValueLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_totalValueLabel];
    }
    return _totalValueLabel;
}

@end

