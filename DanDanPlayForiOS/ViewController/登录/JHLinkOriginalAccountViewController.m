//
//  JHLinkOriginalAccountViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHLinkOriginalAccountViewController.h"
#import "JHTextField.h"
#import "JHBaseScrollView.h"

@interface JHLinkOriginalAccountViewController ()
@property (strong, nonatomic) JHTextField *accountTextField;
@property (strong, nonatomic) JHTextField *passwordTextField;
@property (strong, nonatomic) UIButton *linkButton;
@property (strong, nonatomic) JHBaseScrollView *scrollView;
@end

@implementation JHLinkOriginalAccountViewController

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
    
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (account.length == 0) {
        [MBProgressHUD showWithText:@"请输入账号！"];
        return;
    }
    
    if (password.length == 0) {
        [MBProgressHUD showWithText:@"请输入密码！"];
        return;
    }
    
    JHRegisterRequest *request = [[JHRegisterRequest alloc] init];
    request.userId = [NSString stringWithFormat:@"%ld", self.user.identity];
    request.token = self.user.token;
    request.account = account;
    request.password = password;
    
    MBProgressHUD *aHud = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeIndeterminate InView:self.view];
    aHud.label.text = @"绑定中...";
    [LoginNetManager loginRegisterRelateOnlyWithRequest:request completionHandler:^(JHRegisterResponse *responseObject, NSError *error) {
        
        if (error) {
            [aHud hideAnimated:YES];
            [MBProgressHUD showWithError:error];
        }
        else {
            aHud.label.text = @"登录中...";
            
            [LoginNetManager loginWithSource:JHUserTypeDefault userId:account token:password completionHandler:^(JHUser *responseObject1, NSError *error1) {
                [aHud hideAnimated:YES];
                
                if (error1) {
                    [MBProgressHUD showWithError:error1];
                }
                else {
                    [CacheManager shareCacheManager].user = responseObject1;
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }];
}

#pragma mark - 懒加载
- (JHBaseScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[JHBaseScrollView alloc] init];
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

- (JHTextField *)accountTextField {
    if (_accountTextField == nil) {
        _accountTextField = [[JHTextField alloc] initWithType:JHTextFieldTypeNormal];
        _accountTextField.placeholder = @"用户名（英文数字5-20位）";
        _accountTextField.returnKeyType = UIReturnKeyDone;
        _accountTextField.limit = 20;
    }
    return _accountTextField;
}

- (JHTextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[JHTextField alloc] initWithType:JHTextFieldTypePassword];
        _passwordTextField.placeholder = @"密码（5-20位）";
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.limit = 20;
        [_passwordTextField touchSeeButton:_passwordTextField.rightButton];
    }
    return _passwordTextField;
}

- (UIButton *)linkButton {
    if (_linkButton == nil) {
        _linkButton = [[UIButton alloc] init];
        _linkButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _linkButton.backgroundColor = MAIN_COLOR;
        [_linkButton setTitle:@"确定" forState:UIControlStateNormal];
        _linkButton.layer.cornerRadius = 6;
        _linkButton.layer.masksToBounds = YES;
        [_linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _linkButton;
}

@end
