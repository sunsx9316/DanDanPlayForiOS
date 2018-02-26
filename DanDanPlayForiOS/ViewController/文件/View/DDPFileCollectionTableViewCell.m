//
//  DDPFileCollectionTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileCollectionTableViewCell.h"
#import "UIView+Tools.h"

@implementation DDPFileCollectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_offset(15);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(0);
        }];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont ddp_normalSizeFont];
        _detailLabel.textColor = [UIColor lightGrayColor];
        [_detailLabel setRequiredContentHorizontalResistancePriority];
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

@end
