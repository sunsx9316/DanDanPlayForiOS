//
//  OtherSettingTitleSubtitleTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "OtherSettingTitleSubtitleTableViewCell.h"

@implementation OtherSettingTitleSubtitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = VERY_LIGHT_GRAY_COLOR;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.right.equalTo(self.detailLabel.mas_left).mas_offset(-10);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.right.mas_offset(-10);
            make.bottom.mas_offset(-10);
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = NORMAL_SIZE_FONT;
        _detailLabel.textColor = [UIColor darkGrayColor];
        _detailLabel.numberOfLines = 0;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        [_detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

@end
