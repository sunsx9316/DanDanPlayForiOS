//
//  DDPOtherSettingSwitchTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPOtherSettingSwitchTableViewCell.h"

@interface DDPOtherSettingSwitchTableViewCell ()

@end

@implementation DDPOtherSettingSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        let holdView = [[UIStackView alloc] init];
        holdView.spacing = 5;
        holdView.axis = UILayoutConstraintAxisVertical;
        [holdView addArrangedSubview:self.titleLabel];
        [holdView addArrangedSubview:self.detailLabel];

        [self.contentView addSubview:holdView];
        [self.contentView addSubview:self.aSwitch];
        
        [holdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.trailing.mas_offset(-10);
            make.leading.mas_greaterThanOrEqualTo(holdView.mas_trailing).offset(10);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
    self.detailLabel.text = nil;
}

- (void)touchSwitch:(UISwitch *)sender {
    if (self.touchSwitchCallBack) {
        self.touchSwitchCallBack(sender);
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont ddp_smallSizeFont];
        _detailLabel.textColor = [UIColor lightGrayColor];
    }
    return _detailLabel;
}

- (UISwitch *)aSwitch {
    if (_aSwitch == nil) {
        _aSwitch = [[UISwitch alloc] init];
        [_aSwitch addTarget:self action:@selector(touchSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _aSwitch;
}

@end
