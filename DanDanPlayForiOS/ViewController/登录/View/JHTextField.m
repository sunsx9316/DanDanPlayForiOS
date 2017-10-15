//
//  JHTextField.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHTextField.h"

@interface JHTextField ()<UITextFieldDelegate>
@property (strong, nonatomic, readwrite) UIView *lineView;
@end

@implementation JHTextField
{
    JHTextFieldType _type;
}

- (instancetype)initWithType:(JHTextFieldType)type {
    if (self = [super init]) {
        _type = type;
        
        self.enablesReturnKeyAutomatically = YES;
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        if (_type == JHTextFieldTypePassword) {
            self.secureTextEntry = YES;
            self.clearsOnInsertion = YES;
            self.delegate = self;
            
            UIButton *rightButton = [[UIButton alloc] init];
            [rightButton addTarget:self action:@selector(touchSeeButton:) forControlEvents:UIControlEventTouchUpInside];
            [rightButton setImage:[[UIImage imageNamed:@"login_password_selected"] yy_imageByTintColor:MAIN_COLOR] forState:UIControlStateSelected];
            [rightButton setImage:[[UIImage imageNamed:@"login_password_selected"] yy_imageByTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            
            [rightButton sizeToFit];
            rightButton.width += 10;
            self.rightViewMode = UITextFieldViewModeAlways;
            self.rightView = rightButton;
            _rightButton = rightButton;
        }
        
        [self addTarget:self action:@selector(inputText:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

#pragma mark - 私有方法
- (void)inputText:(UITextField *)sender {
    if (_limit == 0) return;
    
    NSString *text = sender.text;
    if (text.length > _limit) {
        sender.text = [text substringToIndex:_limit];
    }
}

- (void)touchSeeButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    NSString *text = self.text;
    self.secureTextEntry = !sender.selected;
    self.text = text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    textField.text = updatedString;
    
    return NO;
}

#pragma mark - 懒加载
- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = RGBCOLOR(230, 230, 230);
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
