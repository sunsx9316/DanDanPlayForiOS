//
//  DDPSMBLoginView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/2/20.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSMBLoginView.h"
#import <YYKeyboardManager.h>

@interface DDPSMBLoginView ()<YYKeyboardObserver>

@end

@implementation DDPSMBLoginView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.helpButton.backgroundColor = nil;
    self.holdView.layer.cornerRadius = 6;
    self.holdView.layer.masksToBounds = YES;
    self.titleLabel.font = [UIFont ddp_normalSizeFont];
    self.addressTextField.font = [UIFont ddp_smallSizeFont];
    self.userNameTextField.font = [UIFont ddp_smallSizeFont];
    self.passwordTextField.font = [UIFont ddp_smallSizeFont];
    [self.loginButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    [self.helpButton setImage:[[UIImage imageNamed:@"file_help"] imageByTintColor:[UIColor ddp_mainColor]] forState:UIControlStateNormal];
    self.helpButton.ddp_hitTestSlop = UIEdgeInsetsMake(-10, -10, -10, -10);
}

- (void)dealloc {
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

- (IBAction)touchLoginButton:(UIButton *)sender {
    if (self.touchLoginButtonCallBack) {
        self.touchLoginButtonCallBack(self);
    }
    
    [self endEditing:YES];
}

- (void)showAtView:(UIView *)view info:(DDPSMBInfo *)info {
    [[YYKeyboardManager defaultManager] addObserver:self];
    if (view) {
        [view addSubview:self];
    }
    self.addressTextField.text = info.hostName.length ? info.hostName : info.ipAddress;
    [self ddp_showViewWithHolderView:self.holdView completion:^(BOOL finished) {
        if (self.addressTextField.text.length > 0) {
            [self.userNameTextField becomeFirstResponder];
        }
        else {
            [self.addressTextField becomeFirstResponder];
        }
    }];
}

- (IBAction)dismiss {
    [self endEditing:YES];
    [self ddp_dismissViewWithCompletion:nil];
}

- (IBAction)touchBgView:(UITapGestureRecognizer *)sender {
    if (self.passwordTextField.isFirstResponder || self.userNameTextField.isFirstResponder || self.addressTextField.isFirstResponder) {
        [self endEditing:YES];
    }
    else {
        [self ddp_dismissViewWithCompletion:nil];
    }
}

- (IBAction)touchHelpButton:(UIButton *)sender {
    if (self.touchHelpButtonCallBack) {
        self.touchHelpButtonCallBack();
    }
    
    [self dismiss];
}



#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (transition.toVisible) {
        float offset = transition.toFrame.size.height;
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            self.holdViewCenterYLayoutConstraint.constant = -offset + 120;
            [self layoutIfNeeded];
        } completion:nil];
    }
    else {
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            self.holdViewCenterYLayoutConstraint.constant = 0;
            [self layoutIfNeeded];
        } completion:nil];
    }
}

@end
