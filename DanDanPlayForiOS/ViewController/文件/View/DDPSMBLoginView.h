//
//  DDPSMBLoginView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/2/20.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DDPSMBLoginViewItem <NSObject>

@property (nonatomic, strong, readonly) NSString *itemHostName;
@property (nonatomic, strong, readonly) NSString *itemUserName;
@property (nonatomic, strong, readonly) NSString *itemPasword;

@end

@interface DDPSMBLoginView : UIView
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *holdView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *holdViewCenterYLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UITextField *workGroupTextField;

@property (copy, nonatomic) void(^touchLoginButtonCallBack)(DDPSMBLoginView *aView);
@property (copy, nonatomic) void(^touchHelpButtonCallBack)(void);

- (void)showAtView:(UIView *)view info:(id<DDPSMBLoginViewItem>)info;
- (void)dismiss;
@end
