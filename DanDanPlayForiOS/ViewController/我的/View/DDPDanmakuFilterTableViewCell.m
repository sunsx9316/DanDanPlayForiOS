//
//  DDPDanmakuFilterTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDanmakuFilterTableViewCell.h"
#import "DDPEdgeButton.h"

@interface DDPDanmakuFilterTableViewCell ()
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *regexButton;
@property (strong, nonatomic) UIButton *enableButton;
@end

@implementation DDPDanmakuFilterTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
        }];
        
        [self.regexButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.nameLabel.mas_right).mas_offset(0);
        }];
        
        [self.enableButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.regexButton);
            make.left.equalTo(self.regexButton.mas_right);
            make.right.mas_offset(0);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(10);
            make.left.equalTo(self.nameLabel);
            make.bottom.mas_offset(-10);
            make.right.equalTo(self.regexButton.mas_left);
        }];
    }
    return self;
}

- (void)setModel:(DDPFilter *)model {
    _model = model;
    self.nameLabel.text = _model.name.length ? _model.name : @"未命名规则";
    self.regexButton.selected = _model.isRegex;
    self.enableButton.selected = _model.enable;
    
    if (_model.isCloudRule) {
        self.titleLabel.text = @"内容是秘密🤓";
        self.regexButton.hidden = YES;
    } else {
        self.titleLabel.text = _model.content;
        self.regexButton.hidden = NO;
    }
}

#pragma mark - 私有方法
- (void)touchEnableButton:(UIButton *)button {
    _model.enable = !_model.enable;
    button.selected = _model.enable;
    if (self.touchEnableButtonCallBack) {
        self.touchEnableButtonCallBack(_model);
    }
}

- (void)touchRegexButton:(UIButton *)button {
    _model.isRegex = !_model.isRegex;
    button.selected = _model.isRegex;
    if (self.touchRegexButtonCallBack) {
        self.touchRegexButtonCallBack(_model);
    }
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont ddp_normalSizeFont];
        [_nameLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [_nameLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor grayColor];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)regexButton {
    if (_regexButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(15, 10);
        _regexButton = aButton;
        _regexButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_regexButton setTitle:@"正" forState:UIControlStateNormal];
        [_regexButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_regexButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateSelected];
        [_regexButton addTarget:self action:@selector(touchRegexButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_regexButton];
    }
    return _regexButton;
}

- (UIButton *)enableButton {
    if (_enableButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(30, 10);
        _enableButton = aButton;
        [_enableButton setImage:[UIImage imageNamed:@"comment_cheak_mark_noselected"] forState:UIControlStateNormal];
        var img = [[UIImage imageNamed:@"comment_cheak_mark_selected"] renderByMainColor];
        [_enableButton setImage:img forState:UIControlStateSelected];
        [_enableButton addTarget:self action:@selector(touchEnableButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_enableButton];
    }
    return _enableButton;
}

@end
