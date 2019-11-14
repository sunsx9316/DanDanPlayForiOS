//
//  DDPLoginViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLoginViewController.h"
#import "DDPRegisterViewController.h"
#import "DDPForgetPasswordViewController.h"

#import "DDPTextField.h"
#import "DDPEdgeButton.h"
#import "DDPBaseScrollView.h"
#import "UIView+Tools.h"
#if !DDPAPPTYPEISMAC
#import <UMSocialCore/UMSocialCore.h>
#import <Bugly/Bugly.h>
#endif
#import "LAContext+Tools.h"
#import "DDPBaseNavigationController.h"

@interface DDPLoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) DDPTextField *userNameTextField;
@property (strong, nonatomic) DDPTextField *passwordTextField;
@property (strong, nonatomic) DDPEdgeButton *registerButton;
@property (strong, nonatomic) DDPEdgeButton *resetPasswordButton;
@property (strong, nonatomic) DDPBaseScrollView *scrollView;
@property (strong, nonatomic) DDPEdgeButton *qqButton;
@property (strong, nonatomic) DDPEdgeButton *weiboButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIView *thirdLoginHolderView;
@end

@implementation DDPLoginViewController

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
    
    [self fillUserInfo];
    
    LAContext *laContext = [[LAContext alloc] init];
    //验证touchID是否可用
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        NSString *biometryType = laContext.biometryTypeStringValue;
        
        //用户同意使用touchID登录 并且上次登录过
        if ([DDPCacheManager shareCacheManager].useTouchIdLogin && [DDPCacheManager shareCacheManager].currentUser) {
            
            [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:[NSString stringWithFormat:@"使用%@登录 %@", biometryType, [DDPCacheManager shareCacheManager].currentUser.name] reply:^(BOOL success, NSError *error) {
                          if (success) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  DDPUser *user = [DDPCacheManager shareCacheManager].currentUser;
                                  if ([user.userType isEqualToString:DDPUserLoginTypeDefault]) {
                                      [self loginWithAccount:user.account password:user.password source:user.userType];
                                  }
                                  else {
                                      [self loginWithAccount:user.thirdPartyUserId password:user.password source:user.userType];
                                  }
                              });
                          }
                          
                          if (error) {
                              LOG_ERROR(DDPLogModuleLogin, @"---failed to evaluate---error: %@---", error.description);
                          }
                      }];
        }
    }
    else {
         LOG_ERROR(DDPLogModuleLogin, @"touchID不可用");
    }
}

- (void)touchLeftItem:(UIButton *)button {
    
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
    else {
        [super touchLeftItem:button];
    }
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
- (void)touchThirdPartyBotton:(UIButton *)sender {
    #if !DDPAPPTYPEISMAC
    UMSocialPlatformType platformType = sender.tag;
    
    @weakify(self)
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:self completion:^(id result, NSError *error) {
        @strongify(self)
        
        if (error) {
            [self.view showWithText:[self UMErrorStringWithError:error]];
        }
        else {
            UMSocialUserInfoResponse *resp = result;
            [self.view showLoadingWithText:@"登录中..."];
            
            [DDPLoginNetManagerOperation loginWithSource:platformType == UMSocialPlatformType_Sina ? DDPUserLoginTypeWeibo : DDPUserLoginTypeQQ userId:resp.uid token:resp.accessToken completionHandler:^(DDPUser *responseObject, NSError *error1) {
                [self.view hideLoading];
                
                if (error1) {
                    [self.view showWithError:error1];
                }
                //登录成功
                else {
                    if (responseObject.registerRequired == YES) {
                        DDPRegisterViewController *vc = [[DDPRegisterViewController alloc] init];
                        vc.user = responseObject;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else {
                        [self.view showWithText:@"登录成功!"];
                        [self touchLeftItem:nil];
                    }
                }
            }];
        }
    }];
#endif
}

- (void)touchRegisterButton:(UIButton *)sender {
    [self.view endEditing:YES];
    DDPRegisterViewController *vc = [[DDPRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchLoginButton {
    [self.view endEditing:YES];
    
    NSString *account = self.userNameTextField.textField.text;
    NSString *password = self.passwordTextField.textField.text;
    
    [self loginWithAccount:account password:password source:DDPUserLoginTypeDefault];
}

- (void)touchForgetButton:(UIButton *)sender {
    DDPForgetPasswordViewController *vc = [[DDPForgetPasswordViewController alloc] init];
    DDPUser *user = [DDPCacheManager shareCacheManager].currentUser;
    if (user == nil) {
        user = [[DDPUser alloc] init];
        user.account = self.userNameTextField.textField.text;
    }
    
    vc.fillUser = user;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                  source:(DDPUserLoginType)source {
    if (account.length == 0) {
        [self.view showWithText:@"请输入登录用户名!"];
        return;
    }
    
    if (password.length == 0) {
        [self.view showWithText:@"请输入登录密码!"];
        return;
    }
    
    [self.view showLoading];
    [DDPLoginNetManagerOperation loginWithSource:source userId:account token:password completionHandler:^(DDPUser *responseObject, NSError *error) {
        [self.view hideLoading];
        
        if (error) {
            [self.view showWithError:error];
        }
        else {
            [self.view showWithText:@"登录成功!"];
            [self touchLeftItem:nil];
        }
    }];
}

- (NSString *)UMErrorStringWithError:(NSError *)error {
    #if !DDPAPPTYPEISMAC
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
#else
    return @"";
#endif
}

- (void)fillUserInfo {
    let user = [DDPCacheManager shareCacheManager].currentUser;
    if ([user.userType isEqualToString:DDPUserLoginTypeDefault]) {
        self.userNameTextField.textField.text = user.account;
        
//        let range = [self.passwordTextField.textField textRangeFromPosition:self.passwordTextField.textField.beginningOfDocument toPosition:self.passwordTextField.textField.endOfDocument];
//        
//        [self.passwordTextField.textField replaceRange:range withText:user.password ?: @""];
    }
}

#pragma mark - 懒加载

- (DDPBaseScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[DDPBaseScrollView alloc] init];
        [_scrollView addSubview:self.iconImgView];
        [_scrollView addSubview:self.userNameTextField];
        [_scrollView addSubview:self.passwordTextField];
        [_scrollView addSubview:self.registerButton];
        [_scrollView addSubview:self.loginButton];
        [_scrollView addSubview:self.resetPasswordButton];
        
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
        
        [self.resetPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.passwordTextField);
            make.top.equalTo(self.registerButton);
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

- (DDPTextField *)userNameTextField {
    if (_userNameTextField == nil) {
        _userNameTextField = [[DDPTextField alloc] initWithType:DDPTextFieldTypeNormal];
        _userNameTextField.textField.placeholder = @"用户名";
    }
    return _userNameTextField;
}

- (DDPTextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[DDPTextField alloc] initWithType:DDPTextFieldTypePassword];
        _passwordTextField.textField.placeholder = @"密码";
        _passwordTextField.textField.delegate = self;
    }
    return _passwordTextField;
}

- (DDPEdgeButton *)registerButton {
    if (_registerButton == nil) {
        _registerButton = [[DDPEdgeButton alloc] init];
        _registerButton.inset = CGSizeMake(0, 10);
        _registerButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_registerButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        [_registerButton setTitle:@"没有账号？去注册" forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(touchRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (DDPEdgeButton *)resetPasswordButton {
    if (_resetPasswordButton == nil) {
        _resetPasswordButton = [[DDPEdgeButton alloc] init];
        _resetPasswordButton.inset = CGSizeMake(0, 10);
        _resetPasswordButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_resetPasswordButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        [_resetPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_resetPasswordButton addTarget:self action:@selector(touchForgetButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetPasswordButton;
}

- (UIView *)thirdLoginHolderView {
    if (_thirdLoginHolderView == nil) {
        _thirdLoginHolderView = [[UIView alloc] init];
        _thirdLoginHolderView.hidden = YES;
        
        UIView *leftLineView = [[UIView alloc] init];
        leftLineView.backgroundColor = DDPRGBColor(230, 230, 230);
        [_thirdLoginHolderView addSubview:leftLineView];
        
        UIView *rightLineView = [[UIView alloc] init];
        rightLineView.backgroundColor = DDPRGBColor(230, 230, 230);
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
        _loginButton.backgroundColor = [UIColor ddp_mainColor];
        _loginButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 6;
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(touchLoginButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (DDPEdgeButton *)qqButton {
    if (_qqButton == nil) {
        _qqButton = [[DDPEdgeButton alloc] init];
        _qqButton.inset = CGSizeMake(20, 20);
#if !DDPAPPTYPEISMAC
        _qqButton.tag = UMSocialPlatformType_QQ;
#endif
        [_qqButton setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
        [_qqButton addTarget:self action:@selector(touchThirdPartyBotton:) forControlEvents:UIControlEventTouchUpInside];
        [_qqButton setRequiredContentVerticalResistancePriority];
        [_qqButton setRequiredContentHorizontalResistancePriority];
    }
    return _qqButton;
}

- (DDPEdgeButton *)weiboButton {
    if (_weiboButton == nil) {
        _weiboButton = [[DDPEdgeButton alloc] init];
        _weiboButton.inset = CGSizeMake(20, 20);
#if !DDPAPPTYPEISMAC
        _weiboButton.tag = UMSocialPlatformType_Sina;
#endif
        [_weiboButton addTarget:self action:@selector(touchThirdPartyBotton:) forControlEvents:UIControlEventTouchUpInside];
        [_weiboButton setImage:[UIImage imageNamed:@"login_weibo"] forState:UIControlStateNormal];
        [_weiboButton setRequiredContentVerticalResistancePriority];
        [_weiboButton setRequiredContentHorizontalResistancePriority];
    }
    return _weiboButton;
}

@end

