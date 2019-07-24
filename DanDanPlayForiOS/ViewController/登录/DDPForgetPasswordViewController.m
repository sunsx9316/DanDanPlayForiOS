//
//  DDPForgetPasswordViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/7/15.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPForgetPasswordViewController.h"
#import "DDPTextField.h"

@interface DDPForgetPasswordViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) DDPTextField *emailTextField;
@property (strong, nonatomic) DDPTextField *accountField;

@property (strong, nonatomic) UIButton *submitButton;
@end

@implementation DDPForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"忘记密码";
    
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (_fillUser == nil) {
        _fillUser = [DDPCacheManager shareCacheManager].currentUser;
    }
    
    DDPUser *user = self.fillUser;
    self.accountField.textField.text = user.account;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DDPUser *user = self.fillUser;
    if (user.account.length) {
        [self.emailTextField becomeFirstResponder];
    }
    else {
        [self.accountField.textField becomeFirstResponder];
    }
}

#pragma mark - 私有方法
- (void)touchSubmitButton {
    NSString *email = self.emailTextField.textField.text;
    NSString *account = self.accountField.textField.text;
    
    if (account.length == 0) {
        [self.scrollView showWithText:@"请输入用户名！" offset:CGPointMake(0, -40)];
        return;
    }
    
    if (email.length == 0) {
        [self.scrollView showWithText:@"请输入邮箱！" offset:CGPointMake(0, -40)];
        return;
    }
    
    [self.view showLoading];
    @weakify(self)
    [DDPLoginNetManagerOperation resetPasswordWithAccount:account email:email completionHandler:^(NSError *error) {
        @strongify(self)
        if (!self) return;
        
        [self.view hideLoading];
        
        if (error) {
            [self.view showWithError:error];
        }
        else {
            [self.view showWithText:@"重置密码成功！请登录邮箱查看"];
        }
    }];
}

#pragma mark - 懒加载

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = false;
        
        [_scrollView addSubview:self.accountField];
        [_scrollView addSubview:self.emailTextField];
        [_scrollView addSubview:self.submitButton];
        
        [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(20);
            make.width.equalTo(_scrollView).mas_offset(-50);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(40);
        }];
        
        [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.accountField.mas_bottom).mas_offset(15);
            make.centerX.mas_equalTo(0);
            make.size.mas_equalTo(self.accountField);
        }];
        
        [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emailTextField.mas_bottom).mas_offset(30);
            make.centerX.mas_equalTo(0);
            make.size.mas_equalTo(self.accountField);
            make.bottom.mas_offset(-100);
        }];
    }
    return _scrollView;
}

- (DDPTextField *)accountField {
    if (_accountField == nil) {
        _accountField = [[DDPTextField alloc] initWithType:DDPTextFieldTypeNormal];
        _accountField.textField.placeholder = @"用户名";
    }
    return _accountField;
}

- (DDPTextField *)emailTextField {
    if (_emailTextField == nil) {
        _emailTextField = [[DDPTextField alloc] initWithType:DDPTextFieldTypeNormal];
        _emailTextField.textField.placeholder = @"邮箱";
    }
    return _emailTextField;
}

- (UIButton *)submitButton {
    if (_submitButton == nil) {
        _submitButton = [[UIButton alloc] init];
        _submitButton.backgroundColor = [UIColor ddp_mainColor];
        _submitButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = 6;
        _submitButton.layer.masksToBounds = YES;
        [_submitButton addTarget:self action:@selector(touchSubmitButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

@end
