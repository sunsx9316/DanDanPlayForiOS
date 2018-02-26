//
//  DDPMatchTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMatchTableViewCell.h"

@interface DDPMatchTableViewCell ()

@end

@implementation DDPMatchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor ddp_veryLightGrayColor];
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.top.mas_offset(10);
            make.right.mas_offset(-15);
//            make.right.equalTo(self.detailLabel.mas_left).mas_offset(-10);
        }];
        
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(10);
            make.left.mas_offset(15);
            make.right.mas_offset(-15);
//            make.right.mas_offset(-10);
            make.bottom.mas_offset(-10);
//            make.width.mas_equalTo(self).multipliedBy(0.5);
        }];

    }
    return self;
}

- (void)setModel:(DDPMatch *)model {
    _model = model;
    self.titleLabel.text = _model.animeTitle;
    self.detailLabel.text = _model.name;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont ddp_normalSizeFont];
        _detailLabel.textColor = [UIColor darkGrayColor];
        _detailLabel.numberOfLines = 0;
//        _detailLabel.textAlignment = NSTextAlignmentRight;
//        [_detailLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
//        [_detailLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}


@end
