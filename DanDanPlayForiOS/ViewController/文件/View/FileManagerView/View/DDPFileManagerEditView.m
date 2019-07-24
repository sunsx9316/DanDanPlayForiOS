//
//  DDPFileManagerEditView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerEditView.h"

@implementation DDPFileManagerEditView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        [self addSubview:self.selectedAllButton];
        [self addSubview:self.moveButton];
        [self addSubview:self.deleteButton];
        [self addSubview:self.cancelButton];
        
        [self.selectedAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_offset(0);
            make.width.height.mas_equalTo(@[self.moveButton, self.deleteButton, self.cancelButton]);
        }];
        
        [self.moveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectedAllButton.mas_right);
            make.centerY.equalTo(self.selectedAllButton);
        }];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.moveButton.mas_right);
            make.centerY.equalTo(self.selectedAllButton);
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.deleteButton.mas_right);
            make.centerY.equalTo(self.selectedAllButton);
            make.right.mas_offset(0);
        }];

    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 懒加载
- (UIButton *)selectedAllButton {
    if (_selectedAllButton == nil) {
        _selectedAllButton = [[UIButton alloc] init];
        [_selectedAllButton setTitle:@"全选" forState:UIControlStateNormal];
        var img = [[UIImage imageNamed:@"comment_cheak_mark_selected"] renderByMainColor];
        [_selectedAllButton setImage:img forState:UIControlStateSelected];
        [_selectedAllButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        _selectedAllButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        _selectedAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    return _selectedAllButton;
}

- (UIButton *)moveButton {
    if (_moveButton == nil) {
        _moveButton = [[UIButton alloc] init];
        [_moveButton setTitle:@"移动至..." forState:UIControlStateNormal];
        _moveButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_moveButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    }
    return _moveButton;
}

- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_deleteButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_cancelButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

@end
