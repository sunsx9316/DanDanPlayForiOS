//
//  JHFilterMenuItem.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFilterMenuItem.h"

@implementation JHFilterMenuItem

- (instancetype)initWithItem:(WMMenuItem *)item {
    if (self = [self initWithFrame:item.frame]) {
        self.tag = item.tag;
        self.delegate = item.delegate;
        self.text = item.text;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.normalSize    = item.normalSize;
        self.selectedSize  = item.selectedSize;
        self.normalColor   = item.normalColor;
        self.selectedColor = item.selectedColor;
        self.speedFactor   = item.speedFactor;
        self.font = item.font;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.width.mas_equalTo(1);
            make.right.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)setText:(NSString *)text {
    [self.button setTitle:text forState:UIControlStateNormal];
}

- (NSString *)text {
    return [self.button titleForState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)textColor {
    [self.button setTitleColor:textColor forState:UIControlStateNormal];
}

- (UIColor *)textColor {
    return [self.button titleColorForState:UIControlStateNormal];
}

#pragma mark - 懒加载
- (UIButton *)button {
    if (_button == nil) {
        _button = [[UIButton alloc] init];
        _button.userInteractionEnabled = NO;
        _button.titleLabel.font = [UIFont ddp_normalSizeFont];
        _button.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
        [_button setImage:[[UIImage imageNamed:@"filter_arrow_down"] yy_imageByTintColor:[UIColor ddp_mainColor]] forState:UIControlStateNormal];
        [self addSubview:_button];
    }
    return _button;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = DDPRGBColor(230, 230, 230);
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
