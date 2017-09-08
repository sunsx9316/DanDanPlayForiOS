//
//  AttentionDetailTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionDetailTableViewCell.h"
#include "JHEdgeLabel.h"
#import "NSDate+Tools.h"

@interface AttentionDetailTableViewCell ()
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) JHEdgeLabel *onAirLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *viewLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@end

@implementation AttentionDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.width.mas_offset(90);
            make.height.mas_offset(120);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.onAirLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.iconImgView).mas_offset(-5);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(15);
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.viewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(10);
            make.left.equalTo(self.nameLabel);
            make.right.mas_offset(-10);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.viewLabel.mas_bottom).mas_offset(10);
            make.left.equalTo(self.nameLabel);
            make.right.mas_offset(-10);
            make.bottom.mas_offset(-15);
        }];
    }
    return self;
}

- (void)setModel:(JHFavorite *)model {
    _model = model;
    [self.iconImgView jh_setImageWithURL:_model.imageUrl];
    [self.blurView.layer jh_setImageWithURL:_model.imageUrl];
    self.onAirLabel.hidden = !_model.isOnAir;
    self.nameLabel.text = _model.name;
    self.viewLabel.text = [NSString stringWithFormat:@"已看%ld集 , 共%ld集", _model.episodeWatched, _model.episodeTotal];
    NSDate *date = [NSDate dateWithDefaultFormatString:_model.attentionTime];
    self.timeLabel.text = [NSString stringWithFormat:@"关注于: %@", [NSDate attentionTimeStyleWithDate:date]];
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

- (JHEdgeLabel *)onAirLabel {
    if (_onAirLabel == nil) {
        _onAirLabel = [[JHEdgeLabel alloc] init];
        _onAirLabel.font = SMALL_SIZE_FONT;
        _onAirLabel.textColor = [UIColor whiteColor];
        _onAirLabel.text = @"连载中";
        _onAirLabel.textAlignment = NSTextAlignmentCenter;
        _onAirLabel.backgroundColor = MAIN_COLOR;
        _onAirLabel.inset = CGSizeMake(5, 5);
        [self.contentView addSubview:_onAirLabel];
    }
    return _onAirLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NORMAL_SIZE_FONT;
        _nameLabel.numberOfLines = 2;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)viewLabel {
    if (_viewLabel == nil) {
        _viewLabel = [[UILabel alloc] init];
        _viewLabel.font = SMALL_SIZE_FONT;
        _viewLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_viewLabel];
    }
    return _viewLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = SMALL_SIZE_FONT;
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIVisualEffectView *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [self.contentView addSubview:_blurView];
    }
    return _blurView;
}

@end
