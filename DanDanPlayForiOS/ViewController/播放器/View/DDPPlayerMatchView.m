//
//  DDPPlayerMatchView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/3/10.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerMatchView.h"
#import "DDPEdgeButton.h"

@interface DDPPlayerMatchView ()
@property (strong, nonatomic) UIButton *customMathButton;
@end

@implementation DDPPlayerMatchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.customMathButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(8);
        }];
        
        [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.customMathButton.mas_right).mas_offset(8);
            make.right.mas_offset(-5);
        }];
    }
    return self;
}

#pragma mark - 私有方法
- (void)touchCustomMathButton:(UIButton *)button {
    if (self.touchMatchButtonCallBack) {
        self.touchMatchButtonCallBack();
    }
}

#pragma mark - 懒加载
- (UIButton *)customMathButton {
    if (_customMathButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(10, 8);
        _customMathButton = aButton;
        [_customMathButton setTitle:@"手动匹配" forState:UIControlStateNormal];
        _customMathButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        _customMathButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _customMathButton.layer.borderWidth = 1;
        _customMathButton.layer.cornerRadius = 6;
        _customMathButton.layer.masksToBounds = YES;
        
        [_customMathButton addTarget:self action:@selector(touchCustomMathButton:) forControlEvents:UIControlEventTouchUpInside];
        [_customMathButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_customMathButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_customMathButton];
    }
    return _customMathButton;
}

@end
