//
//  DDPPlayerStepTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerStepTableViewCell.h"


@interface DDPPlayerStepTableViewCell ()
@property (strong, nonatomic) UIStepper *stepper;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation DDPPlayerStepTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(5);
            make.bottom.mas_offset(-5);
        }];
        
        [self.stepper mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(5);
            make.bottom.mas_offset(-5);
            make.right.mas_offset(-10);
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
        }];
        
        [self formatterTextWithValue:DDPCacheManager.shareCacheManager.danmakuOffsetTime];
    }
    return self;
}

- (void)touchStepper:(UIStepper *)stepper {
    
    [self formatterTextWithValue:stepper.value];
    
    if (self.touchStepperCallBack) {
        self.touchStepperCallBack(stepper.value);
    }
}

- (void)formatterTextWithValue:(CGFloat)value {
    self.titleLabel.text = [NSString stringWithFormat:@"%lds", (long)value];
}

#pragma mark - 懒加载
- (UIStepper *)stepper {
    if (_stepper == nil) {
        _stepper = [[UIStepper alloc] init];
        _stepper.minimumValue = -CGFLOAT_MAX;
        _stepper.maximumValue = CGFLOAT_MAX;
        _stepper.value = DDPCacheManager.shareCacheManager.danmakuOffsetTime;
        _stepper.tintColor = [UIColor ddp_mainColor];
        [_stepper addTarget:self action:@selector(touchStepper:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_stepper];
    }
    return _stepper;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"0s";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
