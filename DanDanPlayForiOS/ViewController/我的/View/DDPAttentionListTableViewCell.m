//
//  DDPAttentionListTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPAttentionListTableViewCell.h"
#import "NSDate+Tools.h"

@interface DDPAttentionListTableViewCell ()
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) DDPEdgeLabel *onAirLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *viewLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation DDPAttentionListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.centerY.mas_equalTo(0);
            if (ddp_appType == DDPAppTypeToMac) {
                make.width.mas_offset(120);
                make.height.mas_offset(140);
            } else {
                make.width.mas_offset(60);
                make.height.mas_offset(80);
            }
        }];
        
        [self.onAirLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.iconImgView).mas_offset(-5);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (ddp_appType == DDPAppTypeToMac) {
                make.top.mas_offset(20);
            } else {
                make.top.mas_offset(10);
            }
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.viewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (ddp_appType == DDPAppTypeToMac) {
                make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(30);
            } else {
                make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(10);
            }
            make.left.equalTo(self.nameLabel);
            make.right.mas_offset(-10);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (ddp_appType == DDPAppTypeToMac) {
                make.top.equalTo(self.viewLabel.mas_bottom).mas_offset(30);
                make.bottom.mas_offset(-20);
            } else {
                make.top.equalTo(self.viewLabel.mas_bottom).mas_offset(10);
                make.bottom.mas_offset(-10);
            }
            make.left.equalTo(self.nameLabel);
            make.right.mas_offset(-10);
        }];
    }
    return self;
}

- (void)setModel:(DDPFavorite *)model {
    _model = model;
    [self.iconImgView ddp_setImageWithURL:_model.imageUrl];
    self.onAirLabel.hidden = !_model.isOnAir;
    self.nameLabel.text = _model.name;
    self.viewLabel.text = [NSString stringWithFormat:@"已看%lu集 , 共%lu集", (unsigned long)_model.episodeWatched, (unsigned long)_model.episodeTotal];
    NSDate *date = [NSDate dateWithDefaultFormatString:_model.attentionTime];
    self.timeLabel.text = [NSString stringWithFormat:@"关注于: %@", [NSDate attentionTimeStyleWithDate:date]];
}

- (void)setInfoModel:(DDPBangumiQueueIntro *)infoModel {
    _infoModel = infoModel;
    [self.iconImgView ddp_setImageWithURL:_infoModel.imageUrl];
    self.nameLabel.text = _infoModel.name;
    if (_infoModel.lastWatched.length > 0) {
        self.viewLabel.text = [NSString stringWithFormat:@"上次观看于 %@", [NSDate lastWatchTimeStyleWithDate:[NSDate dateWithDefaultFormatString:_infoModel.lastWatched]]];
    }
    else {
        self.viewLabel.text = @"未观看";
    }
    self.onAirLabel.hidden = _infoModel.isOnAir;
    DDPBangumiEpisode *episode = infoModel.collection.firstObject;
    self.timeLabel.text = episode.name.length ? episode.name : @" ";
}

#pragma mark - 懒加载
- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView.clipsToBounds = YES;
        [self.contentView addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (DDPEdgeLabel *)onAirLabel {
    if (_onAirLabel == nil) {
        _onAirLabel = [[DDPEdgeLabel alloc] init];
        _onAirLabel.font = [UIFont ddp_verySmallSizeFont];
        _onAirLabel.textColor = [UIColor whiteColor];
        _onAirLabel.text = @"连载中";
        _onAirLabel.textAlignment = NSTextAlignmentCenter;
        _onAirLabel.backgroundColor = [UIColor ddp_mainColor];
        _onAirLabel.inset = CGSizeMake(5, 5);
        [self.contentView addSubview:_onAirLabel];
    }
    return _onAirLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont ddp_normalSizeFont];
        _nameLabel.numberOfLines = 2;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)viewLabel {
    if (_viewLabel == nil) {
        _viewLabel = [[UILabel alloc] init];
        _viewLabel.font = [UIFont ddp_smallSizeFont];
        _viewLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_viewLabel];
    }
    return _viewLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont ddp_smallSizeFont];
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

@end
