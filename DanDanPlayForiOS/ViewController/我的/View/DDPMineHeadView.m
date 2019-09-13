//
//  DDPMineHeadView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/5.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPMineHeadView.h"
#import "DDPLoginViewController.h"

@interface DDPMineHeadView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *holdViewCenterYConstraint;

@end

@implementation DDPMineHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconWidthConstraint.constant = 90 + ddp_isPad() * 40;
    self.iconImgView.layer.cornerRadius = self.iconWidthConstraint.constant / 2;
    self.iconImgView.layer.masksToBounds = true;
    self.iconImgView.layer.borderWidth = 5;
    self.iconImgView.layer.borderColor = DDPRGBAColor(255, 255, 255, 0.6).CGColor;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont ddp_normalSizeFont];
    self.idLabel.textColor = [UIColor lightGrayColor];
    self.idLabel.font = [UIFont ddp_verySmallSizeFont];
    
    self.holdViewCenterYConstraint.constant = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame);
    
    self.autoresizingMask = UIViewAutoresizingNone;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesHeader)]];
}

- (void)setModel:(DDPUser *)model {
    _model = model;
    
    if (_model.isLogin == false) {
        self.nameLabel.text = @"点击登录";
        self.idLabel.text = nil;
        [self.iconImgView ddp_setImageWithURL:nil placeholder:[UIImage imageNamed:@"comment_icon"]];
    }
    else {
        [self.iconImgView ddp_setImageWithURL:_model.iconImgURL placeholder:[UIImage imageNamed:@"comment_icon"]];
        self.nameLabel.text = _model.name;
        self.idLabel.text = [NSString stringWithFormat:@"@%@", _model.account];
    }
}

- (void)touchesHeader {
    DDPUser *user = [DDPCacheManager shareCacheManager].currentUser;
    if (user.isLogin == false) {
        DDPLoginViewController *vc = [[DDPLoginViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }
    else {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
//        if ([user.userType isEqualToString:DDPUserLoginTypeDefault]) {
            [vc addAction:[UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self editPassword];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"修改昵称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self editName];
            }]];
//        }
        
        [vc addAction:[UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[DDPCacheManager shareCacheManager].currentUser updateLoginStatus:false];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        if (ddp_isPad()) {
            vc.popoverPresentationController.sourceView = self.viewController.view;
            vc.popoverPresentationController.sourceRect = [self.viewController.view convertRect:self.nameLabel.frame fromView:self];
        }
        
        [self.viewController presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - 私有方法
- (void)editName {
    DDPUser *user = [DDPCacheManager shareCacheManager].currentUser;
    
    if (user.isLogin == false) return;
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(avc)
    [avc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *name = weak_avc.textFields.firstObject.text;
        
        if (name.length == 0) {
            [self.viewController.view showWithText:@"请输入昵称!"];
            return;
        }
        
        [self.viewController.view showLoading];
        @weakify(self)
        [DDPLoginNetManagerOperation editUserNameWithUserName:name completionHandler:^(NSError *error) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.viewController.view hideLoading];
            
            if (error) {
                [self.viewController.view showWithError:error];
            }
            else {
                [self.viewController.view showWithText:@"修改成功!"];
                user.name = name;
                [DDPCacheManager shareCacheManager].currentUser = user;
            }
        }];
    }]];
    
    [avc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [avc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"请输入昵称";
        textField.text = user.name;
    }];
    
    [self.viewController presentViewController:avc animated:YES completion:nil];
}

- (void)editPassword {
    DDPUser *user = [DDPCacheManager shareCacheManager].currentUser;
    
    
    if (user.isLogin == false) return;
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"修改密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(avc)
    [avc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *oldPassword = weak_avc.textFields.firstObject.text;
        NSString *newPassword = weak_avc.textFields[1].text;
        
        if (oldPassword.length == 0) {
            [self.viewController.view showWithText:@"请输入原密码！"];
            return;
        }
        
        if (newPassword.length == 0) {
            [self.viewController.view showWithText:@"请输入新密码！"];
            return;
        }
        
        [self.viewController.view showLoading];
        
        @weakify(self)
        [DDPLoginNetManagerOperation editPasswordWithOldPassword:oldPassword aNewPassword:newPassword completionHandler:^(NSError *error) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.viewController.view hideLoading];
            if (error) {
                [self.viewController.view showWithError:error];
            }
            else {
                [self.viewController.view showWithText:@"修改成功！"];
            }
        }];
    }]];
    
    [avc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [avc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"原密码";
        textField.secureTextEntry = YES;
        textField.textColor = nil;
    }];
    
    [avc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"新密码";
        textField.secureTextEntry = YES;
        textField.textColor = nil;
    }];
    
    [self.viewController presentViewController:avc animated:YES completion:nil];
}


@end
