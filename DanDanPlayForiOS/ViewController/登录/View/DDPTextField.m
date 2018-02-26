//
//  DDPTextField.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPTextField.h"
#import "DDPEdgeButton.h"
#import "UIView+Tools.h"

@interface DDPTextField ()<UITextFieldDelegate>
@property (strong, nonatomic, readwrite) UIView *lineView;
@property (strong, nonatomic) UILabel *previewPasswordLabel;
@end

@implementation DDPTextField
{
    DDPTextFieldType _type;
}

- (instancetype)initWithType:(DDPTextFieldType)type {
    if (self = [super init]) {
        _type = type;
        
        if (_type == DDPTextFieldTypePassword) {
            self.textField.secureTextEntry = YES;
            self.textField.clearsOnInsertion = YES;
            self.textField.keyboardType = UIKeyboardTypeASCIICapable;
            self.textField.returnKeyType = UIReturnKeyDone;
            
            DDPEdgeButton *rightButton = [[DDPEdgeButton alloc] init];
            rightButton.inset = CGSizeMake(10, 10);
            [rightButton setRequiredContentHorizontalResistancePriority];
            [rightButton addTarget:self action:@selector(touchDownSeeButton:) forControlEvents:UIControlEventTouchDown];
            [rightButton addTarget:self action:@selector(touchUpSeeButton:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
            [rightButton setImage:[[UIImage imageNamed:@"login_password_selected"] yy_imageByTintColor:[UIColor ddp_mainColor]] forState:UIControlStateSelected];
            [rightButton setImage:[[UIImage imageNamed:@"login_password_selected"] yy_imageByTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            
            _rightButton = rightButton;
            [self addSubview:_rightButton];
            
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.mas_equalTo(0);
            }];
            
            [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.right.mas_offset(-10);
                make.left.equalTo(self.textField.mas_right).mas_offset(10);
            }];
            
            [self.previewPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.textField);
            }];
        }
        else {
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.mas_equalTo(0);
            }];
        }
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
            make.top.equalTo(self.textField.mas_bottom);
        }];
    }
    return self;
}

#pragma mark - 私有方法
- (void)inputText:(UITextField *)sender {
    self.previewPasswordLabel.text = sender.text;
    
    if (_limit == 0) return;
    
    NSString *text = sender.text;
    if (text.length > _limit) {
        sender.text = [text substringToIndex:_limit];
    }
}

- (void)touchDownSeeButton:(UIButton *)sender {
    self.previewPasswordLabel.hidden = NO;
    self.textField.hidden = YES;
}

- (void)touchUpSeeButton:(UIButton *)sender {
    self.previewPasswordLabel.hidden = YES;
    self.textField.hidden = NO;
}

#pragma mark - 懒加载
- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = DDPRGBColor(230, 230, 230);
        [self addSubview:_lineView];
    }
    return _lineView;
}

- (UILabel *)previewPasswordLabel {
    if (_previewPasswordLabel == nil) {
        _previewPasswordLabel = [[UILabel alloc] init];
        _previewPasswordLabel.font = [UIFont ddp_normalSizeFont];
        _previewPasswordLabel.hidden = YES;
        [self addSubview:_previewPasswordLabel];
    }
    return _previewPasswordLabel;
}

- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont ddp_normalSizeFont];
        _textField.enablesReturnKeyAutomatically = YES;
        [_textField addTarget:self action:@selector(inputText:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_textField];
    }
    return _textField;
}

@end

