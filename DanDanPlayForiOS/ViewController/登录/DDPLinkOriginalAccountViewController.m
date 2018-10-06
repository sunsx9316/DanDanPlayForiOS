//
//  DDPLinkOriginalAccountViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkOriginalAccountViewController.h"
#import "DDPTextField.h"
#import "DDPBaseScrollView.h"

@interface DDPLinkOriginalAccountViewController ()
@property (strong, nonatomic) DDPTextField *accountTextField;
@property (strong, nonatomic) DDPTextField *passwordTextField;
@property (strong, nonatomic) UIButton *linkButton;
@property (strong, nonatomic) DDPBaseScrollView *scrollView;
@end

@implementation DDPLinkOriginalAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"绑定已有帐号";
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - 懒加载
- (void)touchLinkButton:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString *account = self.accountTextField.textField.text;
    NSString *password = self.passwordTextField.textField.text;
    
    if (account.length == 0) {
        [self.view showWithText:@"请输入账号!"];
        return;
    }
    
    if (password.length == 0) {
        [self.view showWithText:@"请输入密码!"];
        return;
    }
    
    DDPRegisterRequest *request = [[DDPRegisterRequest alloc] init];
    request.userId = [NSString stringWithFormat:@"%lu", (unsigned long)self.user.identity];
    request.token = self.user.legacyTokenNumber;
    request.account = account;
    request.password = password;
    
    MBProgressHUD *aHud = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeIndeterminate InView:self.view];
    aHud.label.text = @"绑定中...";
    [DDPLoginNetManagerOperation relateOnlyWithRequest:request completionHandler:^(NSError *error) {
        if (error) {
            [aHud hideAnimated:YES];
            [self.view showWithError:error];
        }
        else {
            aHud.label.text = @"登录中...";
            
            [DDPLoginNetManagerOperation loginWithSource:DDPUserLoginTypeDefault userId:account token:password completionHandler:^(DDPUser *responseObject1, NSError *error1) {
                [aHud hideAnimated:YES];
                
                if (error1) {
                    [self.view showWithError:error1];
                }
                else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self.view showWithText:@"登录成功!"];
                }
            }];
        }
    }];
}

#pragma mark - 懒加载
- (DDPBaseScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[DDPBaseScrollView alloc] init];
        [_scrollView addSubview:self.accountTextField];
        [_scrollView addSubview:self.passwordTextField];
        [_scrollView addSubview:self.linkButton];
        
        CGFloat edge = 15;
        
        [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_scrollView).mas_offset(-50);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(0);
            make.top.mas_offset(edge);
        }];
        
        [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.centerX.mas_equalTo(self.accountTextField);
            make.top.equalTo(self.accountTextField.mas_bottom).mas_offset(edge);
        }];
        
        [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_scrollView).mas_offset(-30);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(44);
            make.top.equalTo(self.passwordTextField.mas_bottom).mas_offset(edge + 10);
        }];
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (DDPTextField *)accountTextField {
    if (_accountTextField == nil) {
        _accountTextField = [[DDPTextField alloc] initWithType:DDPTextFieldTypeNormal];
        _accountTextField.textField.placeholder = @"用户名";
        _accountTextField.textField.returnKeyType = UIReturnKeyDone;
        _accountTextField.limit = 20;
    }
    return _accountTextField;
}

- (DDPTextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[DDPTextField alloc] initWithType:DDPTextFieldTypePassword];
        _passwordTextField.textField.placeholder = @"密码";
        _passwordTextField.textField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.limit = 20;
        //        [_passwordTextField touchSeeButton:_passwordTextField.rightButton];
    }
    return _passwordTextField;
}

- (UIButton *)linkButton {
    if (_linkButton == nil) {
        _linkButton = [[UIButton alloc] init];
        _linkButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _linkButton.backgroundColor = [UIColor ddp_mainColor];
        [_linkButton setTitle:@"确定" forState:UIControlStateNormal];
        _linkButton.layer.cornerRadius = 6;
        _linkButton.layer.masksToBounds = YES;
        [_linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _linkButton;
}

@end

