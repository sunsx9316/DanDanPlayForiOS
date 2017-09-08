//
//  AttentionDetailHistoryTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionDetailHistoryTableViewCell.h"
#import "JHEdgeLabel.h"

@interface AttentionDetailHistoryTableViewCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation AttentionDetailHistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.right.mas_offset(-10);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)setModel:(JHEpisode *)model {
    _model = model;
    self.titleLabel.text = _model.name;
    if (_model.time.length) {
        self.timeLabel.text = [NSString stringWithFormat:@"上次观看时间: %@", _model.time];
    }
    else {
        self.timeLabel.text = nil;
    }
}

#pragma mark - 懒加载

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        JHEdgeLabel *label = [[JHEdgeLabel alloc] init];
        label.inset = CGSizeMake(0, 20);
        _timeLabel = label;
        _timeLabel.font = NORMAL_SIZE_FONT;
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

@end
