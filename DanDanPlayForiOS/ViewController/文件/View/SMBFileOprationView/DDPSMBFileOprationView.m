//
//  DDPSMBFileOprationView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSMBFileOprationView.h"

@interface DDPSMBFileOprationView ()
@property (strong, nonatomic) CALayer *lineLayer;
@end

@implementation DDPSMBFileOprationView

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lineLayer.frame = CGRectMake(0, 0, self.width, 1);
}

#pragma mark - 懒加载
- (UIButton *)selectedAllButton {
    if (_selectedAllButton == nil) {
        _selectedAllButton = [[UIButton alloc] init];
        [_selectedAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [_selectedAllButton setTitle:@"取消全选" forState:UIControlStateSelected];
        [_selectedAllButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        _selectedAllButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [self addSubview:_selectedAllButton];
    }
    return _selectedAllButton;
}

- (UIButton *)downloadButton {
    if (_downloadButton == nil) {
        _downloadButton = [[UIButton alloc] init];
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [self addSubview:_downloadButton];
    }
    return _downloadButton;
}

- (CALayer *)lineLayer {
    if (_lineLayer == nil) {
        _lineLayer = [CALayer layer];
        _lineLayer.backgroundColor = [UIColor ddp_lightGrayColor].CGColor;
        [self.layer addSublayer:_lineLayer];
    }
    return _lineLayer;
}


@end
