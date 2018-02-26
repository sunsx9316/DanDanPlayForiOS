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
@end

@implementation DDPAttentionDetailHistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.mas_equalTo(0);
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(-10);
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(5);
            make.left.equalTo(self.timeLabel.mas_right).mas_offset(5);
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
    
    self.playButton.hidden = _model.linkFile == nil;
}

#pragma mark - 私有方法
- (void)touchPlayButton:(UIButton *)sender {
    if (self.touchPlayButtonCallBack) {
        self.touchPlayButtonCallBack(_model.linkFile);
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
        [self.contentView addSubview:_playButton];
    }
    return _playButton;
}

@end
