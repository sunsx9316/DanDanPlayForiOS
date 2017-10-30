//
//  JHLoginViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHLoginViewController.h"
#import "JHRegisterViewController.h"

#import "JHTextField.h"
#import "JHEdgeButton.h"
#import "JHBaseScrollView.h"
#import "UIView+Tools.h"
#import <UMSocialCore/UMSocialCore.h>
#import <Bugly/Bugly.h>

CG_INLINE NSString *UMErrorStringWithError(NSError *error) {
    switch (error.code) {
        case UMSocialPlatformErrorType_NotSupport:
            return @"客户端不支持该操作";
        case UMSocialPlatformErrorType_AuthorizeFailed:
            return @"授权失败";
        case UMSocialPlatformErrorType_ShareFailed:
            return @"分享失败";
        case UMSocialPlatformErrorType_RequestForUserProfileFailed:
            return @"请求用户信息失败";
        case UMSocialPlatformErrorType_ShareDataNil:
            return @"分享内容为空";
        case UMSocialPlatformErrorType_ShareDataTypeIllegal:
            return @"不支持该分享内容";
        case UMSocialPlatformErrorType_CheckUrlSchemaFail:
            return @"不支持该分享内容";
        case UMSocialPlatformErrorType_NotInstall:
            return @"应用未安装";
        case UMSocialPlatformErrorType_Cancel:
            return @"用户取消操作";
        case UMSocialPlatformErrorType_NotUsingHttps:
        case UMSocialPlatformErrorType_NotNetWork:
            return @"网络异常";
        case UMSocialPlatformErrorType_SourceError:
            return @"第三方错误";
        default:
            return @"未知错误";
            break;
    }
};

@interface JHLoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) JHTextField *userNameTextField;
@property (strong, nonatomic) JHTextField *passwordTextField;
@property (strong, nonatomic) JHEdgeButton *registerButton;
@property (strong, nonatomic) JHBaseScrollView *scrollView;
@property (strong, nonatomic) JHEdgeButton *qqButton;
@property (strong, nonatomic) JHEdgeButton *weiboButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIView *thirdLoginHolderView;
@end

@implementation JHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"登录";
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.thirdLoginHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-20);
        make.left.right.mas_equalTo(0);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self touchLoginButton];
    return NO;
}

#pragma mark - 私有方法

/**
 第三方登录
 
 @param sender 按钮
 */
- (void)touchBotton:(UIButton *)sender {
    UMSocialPlatformType platformType = sender.tag;
    
    [MBProgressHUD showLoadingInView:self.view text:nil];
    [MBProgressHUD hideLoading];
    
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:self completion:^(id result, NSError *error) {
        [MBProgressHUD hideLoading];
        
        if (error) {
            [MBProgressHUD showWithText:UMErrorStringWithError(error) atView:self.view];
        }
        else {
            UMSocialUserInfoResponse *resp = result;
            [MBProgressHUD showLoadingInView:self.view text:@"登录中..."];
            
            [LoginNetManager loginWithSource:platformType == UMSocialPlatformType_Sina ? JHUserTypeWeibo : JHUserTypeQQ userId:resp.uid token:resp.accessToken completionHandler:^(JHUser *responseObject, NSError *error1) {
                [MBProgressHUD hideLoading];
                
                if (error1) {
                    [MBProgressHUD showWithError:error1 atView:self.view];
                }
                //登录成功
                else {
                    if (responseObject.registerRequired == YES) {
                        JHRegisterViewController *vc = [[JHRegisterViewController alloc] init];
                        vc.user = responseObject;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else {
                        [CacheManager shareCacheManager].user = responseObject;
                        [self.navigationController popViewControllerAnimated:YES];
                        [MBProgressHUD showWithText:@"登录成功！"];
                    }
                }
            }];
        }
    }];
}

- (void)touchRegisterButton:(UIButton *)sender {
    [self.view endEditing:YES];
    JHRegisterViewController *vc = [[JHRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchLoginButton {
    [self.view endEditing:YES];
    
    NSString *account = self.userNameTextField.textField.text;
    NSString *password = self.passwordTextField.textField.text;
    
    if (account.length == 0) {
        [MBProgressHUD showWithText:@"请输入登录用户名！"];
        return;
    }
    
    if (password.length == 0) {
        [MBProgressHUD showWithText:@"请输入登录密码！"];
        return;
    }
    
    [MBProgressHUD showLoadingInView:self.view text:nil];
    [LoginNetManager loginWithSource:JHUserTypeDefault userId:account token:password completionHandler:^(JHUser *responseObject, NSError *error) {
        [MBProgressHUD hideLoading];
        
        if (error) {
            [MBProgressHUD showWithError:error];
        }
        else {
            [CacheManager shareCacheManager].user = responseObject;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [MBProgressHUD showWithText:@"登录成功！"];
        }
    }];
}

#pragma mark - 懒加载

- (JHBaseScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[JHBaseScrollView alloc] init];
        [_scrollView addSubview:self.iconImgView];
        [_scrollView addSubview:self.userNameTextField];
        [_scrollView addSubview:self.passwordTextField];
        [_scrollView addSubview:self.registerButton];
        [_scrollView addSubview:self.loginButton];
        
        CGFloat edge = 15;
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_offset(edge);
            make.width.height.mas_equalTo(80);
        }];
        
        [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_scrollView).mas_offset(-50);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(0);
            make.top.equalTo(self.iconImgView.mas_bottom).mas_offset(edge + 10);
        }];
        
        [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.centerX.mas_equalTo(self.userNameTextField);
            make.top.equalTo(self.userNameTextField.mas_bottom).mas_offset(edge);
        }];
        
        [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.passwordTextField);
            make.top.equalTo(self.passwordTextField.mas_bottom).mas_offset(0);
        }];
        
        [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_scrollView).mas_offset(-30);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(44);
            make.top.equalTo(self.registerButton.mas_bottom).mas_offset(edge);
        }];
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_icon"]];
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.cornerRadius = 40;
    }
    return _iconImgView;
}

- (JHTextField *)userNameTextField {
    if (_userNameTextField == nil) {
        _userNameTextField = [[JHTextField alloc] initWithType:JHTextFieldTypeNormal];
        _userNameTextField.textField.placeholder = @"用户名";
    }
    return _userNameTextField;
}

- (JHTextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[JHTextField alloc] initWithType:JHTextFieldTypePassword];
        _passwordTextField.textField.placeholder = @"密码";
        _passwordTextField.textField.delegate = self;
    }
    return _passwordTextField;
}

- (JHEdgeButton *)registerButton {
    if (_registerButton == nil) {
        _registerButton = [[JHEdgeButton alloc] init];
        _registerButton.inset = CGSizeMake(0, 10);
        _registerButton.titleLabel.font = SMALL_SIZE_FONT;
        [_registerButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_registerButton setTitle:@"没有账号？去注册" forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(touchRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UIView *)thirdLoginHolderView {
    if (_thirdLoginHolderView == nil) {
        _thirdLoginHolderView = [[UIView alloc] init];
        
        UIView *leftLineView = [[UIView alloc] init];
        leftLineView.backgroundColor = RGBCOLOR(230, 230, 230);
        [_thirdLoginHolderView addSubview:leftLineView];
        
        UIView *rightLineView = [[UIView alloc] init];
        rightLineView.backgroundColor = RGBCOLOR(230, 230, 230);
        [_thirdLoginHolderView addSubview:rightLineView];
        
        [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_thirdLoginHolderView);
            make.left.mas_offset(20);
            make.height.mas_equalTo(1);
        }];
        
        UIView *buttonHolderView = [[UIView alloc] init];
        [buttonHolderView addSubview:self.qqButton];
        [buttonHolderView addSubview:self.weiboButton];
        [_thirdLoginHolderView addSubview:buttonHolderView];
        
        [self.qqButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(0);
        }];
        
        [self.weiboButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_equalTo(0);
            make.left.equalTo(self.qqButton.mas_right);
        }];
        
        [buttonHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
            make.left.equalTo(leftLineView.mas_right).mas_offset(10);
        }];
        
        [rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(buttonHolderView.mas_right).mas_offset(10);
            make.centerY.equalTo(_thirdLoginHolderView);
            make.right.mas_offset(-20);
            make.height.mas_equalTo(leftLineView);
        }];
        
        [self.view addSubview:_thirdLoginHolderView];
    }
    return _thirdLoginHolderView;
}

- (UIButton *)loginButton {
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] init];
        _loginButton.backgroundColor = MAIN_COLOR;
        _loginButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 6;
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(touchLoginButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (JHEdgeButton *)qqButton {
    if (_qqButton == nil) {
        _qqButton = [[JHEdgeButton alloc] init];
        _qqButton.inset = CGSizeMake(20, 20);
        _qqButton.tag = UMSocialPlatformType_QQ;
        [_qqButton setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
        [_qqButton addTarget:self action:@selector(touchBotton:) forControlEvents:UIControlEventTouchUpInside];
        [_qqButton setRequiredContentVerticalResistancePriority];
        [_qqButton setRequiredContentHorizontalResistancePriority];
    }
    return _qqButton;
}

- (JHEdgeButton *)weiboButton {
    if (_weiboButton == nil) {
        _weiboButton = [[JHEdgeButton alloc] init];
        _weiboButton.inset = CGSizeMake(20, 20);
        _weiboButton.tag = UMSocialPlatformType_Sina;
        [_weiboButton addTarget:self action:@selector(touchBotton:) forControlEvents:UIControlEventTouchUpInside];
        [_weiboButton setImage:[UIImage imageNamed:@"login_weibo"] forState:UIControlStateNormal];
        [_weiboButton setRequiredContentVerticalResistancePriority];
        [_weiboButton setRequiredContentHorizontalResistancePriority];
    }
    return _weiboButton;
}

@end

