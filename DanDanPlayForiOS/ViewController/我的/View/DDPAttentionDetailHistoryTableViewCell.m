//
//  DDPAttentionDetailHistoryTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPAttentionDetailHistoryTableViewCell.h"
#import "DDPEdgeLabel.h"
#import "UIView+Tools.h"

@interface DDPAttentionDetailHistoryTableViewCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *tagButton;

@property (nonatomic, strong) UIStackView *stackView;
@end

@implementation DDPAttentionDetailHistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.mas_offset(10);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_offset(10);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.mas_lessThanOrEqualTo(0);
        }];
        
        [self.contentView addSubview:self.stackView];
        [self.stackView addArrangedSubview:self.tagButton];
        [self.stackView addArrangedSubview:self.playButton];
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_offset(-5);
            make.centerY.mas_equalTo(self.contentView);
            make.leading.mas_greaterThanOrEqualTo(self.timeLabel.mas_trailing).offset(5);
            make.leading.mas_greaterThanOrEqualTo(self.titleLabel.mas_trailing).offset(5);
        }];
    }
    return self;
}

- (void)setModel:(DDPEpisode *)model {
    _model = model;
    self.titleLabel.text = _model.name;
    if (_model.time.length) {
        self.timeLabel.text = [NSString stringWithFormat:@"上次观看时间: %@", _model.time];
    }
    else {
        self.timeLabel.text = nil;
    }
    
    if (_model.linkFile == nil) {
        if ([self.stackView.arrangedSubviews containsObject:self.playButton]) {
            [self.stackView removeArrangedSubview:self.playButton];
        }
        self.playButton.hidden = YES;
    } else {
        if (![self.stackView.arrangedSubviews containsObject:self.playButton]) {
            [self.stackView insertArrangedSubview:self.playButton atIndex:0];
        }
        self.playButton.hidden = NO;
    }
}

#pragma mark - 私有方法
- (void)touchPlayButton:(UIButton *)sender {
    if (self.touchPlayButtonCallBack) {
        self.touchPlayButtonCallBack(_model.linkFile);
    }
}

- (void)touchTagButton:(UIButton *)button {
    if (self.touchTagButtonCallBack) {
        self.touchTagButtonCallBack(_model.linkFile);
    }
}

#pragma mark - 懒加载

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        DDPEdgeLabel *label = [[DDPEdgeLabel alloc] init];
        label.inset = CGSizeMake(0, 20);
        _timeLabel = label;
        _timeLabel.font = [UIFont ddp_normalSizeFont];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.numberOfLines = 0;
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        _playButton.ddp_hitTestSlop = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_playButton setRequiredContentVerticalResistancePriority];
        [_playButton setRequiredContentHorizontalResistancePriority];
        [_playButton addTarget:self action:@selector(touchPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"bungumi_info_play_icon"] forState:UIControlStateNormal];
    }
    return _playButton;
}

- (UIButton *)tagButton {
    if (_tagButton == nil) {
        _tagButton = [[UIButton alloc] init];
        _tagButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        _tagButton.ddp_hitTestSlop = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_tagButton setTitleColor:UIColor.ddp_mainColor forState:UIControlStateNormal];
        [_tagButton setRequiredContentVerticalResistancePriority];
        [_tagButton setRequiredContentHorizontalResistancePriority];
        [_tagButton addTarget:self action:@selector(touchTagButton:) forControlEvents:UIControlEventTouchUpInside];
        [_tagButton setTitle:@"标记已看" forState:UIControlStateNormal];
    }
    return _tagButton;
}

- (UIStackView *)stackView {
    if (_stackView == nil) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 5;
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentCenter;
    }
    return _stackView;
}

@end
