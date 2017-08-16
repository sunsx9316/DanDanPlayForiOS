//
//  SMBFileOprationView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBFileOprationView.h"

@interface SMBFileOprationView ()

@end

@implementation SMBFileOprationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.selectedAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(0);
        }];
        
        [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.top.mas_equalTo(0);
            make.left.equalTo(self.selectedAllButton.mas_right);
            make.width.equalTo(self.selectedAllButton);
            make.height.mas_equalTo(50);
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
        [_selectedAllButton setTitle:@"取消全选" forState:UIControlStateSelected];
        [_selectedAllButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _selectedAllButton.titleLabel.font = NORMAL_SIZE_FONT;
        [self addSubview:_selectedAllButton];
    }
    return _selectedAllButton;
}

- (UIButton *)downloadButton {
    if (_downloadButton == nil) {
        _downloadButton = [[UIButton alloc] init];
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = NORMAL_SIZE_FONT;
        [self addSubview:_downloadButton];
    }
    return _downloadButton;
}


@end
