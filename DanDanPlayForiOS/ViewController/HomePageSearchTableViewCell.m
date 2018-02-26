//
//  HomePageSearchTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageSearchTableViewCell.h"
#import "DDPEdgeButton.h"

@interface HomePageSearchTableViewCell ()
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *sizeLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) DDPEdgeButton *subTitleButton;
@end

@implementation HomePageSearchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(10);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.subTitleButton);
            make.left.mas_offset(10);
        }];
        
        [self.subTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).mas_offset(10);
            make.right.bottom.mas_offset(-10);
        }];
    }
    return self;
}

- (void)setModel:(DDPDMHYSearch *)model {
    _model = model;
    self.nameLabel.text = _model.name;
    self.sizeLabel.text = _model.fileSize;
    self.timeLabel.text = _model.publishDate;
    [self.subTitleButton setTitle:_model.subgroupName forState:UIControlStateNormal];
    self.typeLabel.text = _model.typeName;
}

#pragma mark - 私有方法
- (void)touchSubTitleButton:(UIButton *)sender {
    if (self.touchSubGroupCallBack) {
        self.touchSubGroupCallBack(_model);
    }
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont ddp_normalSizeFont];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 0;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (_sizeLabel == nil) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.font = [UIFont ddp_smallSizeFont];
        _sizeLabel.textColor = [UIColor grayColor];
        [_sizeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_sizeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_sizeLabel];
    }
    return _sizeLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont ddp_smallSizeFont];
        _timeLabel.textColor = [UIColor grayColor];
        [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)typeLabel {
    if (_typeLabel == nil) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont ddp_smallSizeFont];
        _typeLabel.textColor = [UIColor ddp_mainColor];
        [self.contentView addSubview:_typeLabel];
    }
    return _typeLabel;
}

- (DDPEdgeButton *)subTitleButton {
    if (_subTitleButton == nil) {
        _subTitleButton = [[DDPEdgeButton alloc] init];
        _subTitleButton.inset = CGSizeMake(10, 10);
        _subTitleButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_subTitleButton setBackgroundImage:[UIImage imageNamed:@"home_bangumi_group_bg"] forState:UIControlStateNormal];
        [_subTitleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_subTitleButton addTarget:self action:@selector(touchSubTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_subTitleButton];
    }
    return _subTitleButton;
}

@end
