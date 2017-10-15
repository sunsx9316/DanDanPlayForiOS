//
//  MBProgressHUD+Tools.m
//  Fumuzhihui
//
//  Created by JimHuang on 16/5/11.
//  Copyright © 2016年 aiitec. All rights reserved.
//

#import "MBProgressHUD+Tools.h"
#import <UIKit/UIKit.h>

static MBProgressHUD *progressHUD = nil;

@implementation MBProgressHUD (Tools)
+ (void)showWithText:(NSString *)text {
    [self showWithText:text atView:nil hideAfterDelay:1.3];
}

+ (void)showWithText:(NSString *)text atView:(UIView *)view {
    [self showWithText:text atView:view hideAfterDelay:1.3];
}

+ (void)showWithText:(NSString *)text
              atView:(UIView *)view
          hideAfterDelay:(NSTimeInterval)afterDelay {
    [MBProgressHUD hideHUDForView:view animated:YES];
    
    MBProgressHUD *hud = [self defaultTypeHUDWithMode:MBProgressHUDModeText InView:view];
    hud.label.text = text;
    hud.label.numberOfLines = 0;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

+ (void)showWithError:(NSError *)error {
    [self showWithError:error userInfoKey:NSLocalizedDescriptionKey atView:nil];
}

+ (void)showWithError:(NSError *)error atView:(UIView *)view {
    [self showWithError:error userInfoKey:NSLocalizedDescriptionKey atView:view];
}

+ (void)showWithError:(NSError *)error
          userInfoKey:(NSString *)userInfoKey
               atView:(UIView *)view {
    NSString *errStr = [NSString stringWithFormat:@"%@", error.userInfo[userInfoKey]];
    if (errStr.length == 0) {
        errStr = error.domain;
    }
    
    [self showWithText:errStr atView:view];
}

+ (void)showLoadingInView:(UIView *)view text:(NSString *)text {
    if (!text.length) text = @"加载中...";
    
    [self hideLoading];
    
    progressHUD = [self defaultTypeHUDWithMode:MBProgressHUDModeIndeterminate InView:view];
    progressHUD.label.text = text;
}

+ (instancetype)showProgressHUDInView:(UIView *)view {
    MBProgressHUD *progressHUD = [self defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:view];
    return progressHUD;
}

+ (instancetype)defaultTypeHUDWithMode:(MBProgressHUDMode)mode InView:(UIView *)view {
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    MBProgressHUD *aHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    aHUD.mode = mode;
    aHUD.bezelView.color = RGBACOLOR(0, 0, 0, 0.8);
    aHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    aHUD.label.textColor = [UIColor whiteColor];
    aHUD.label.font = NORMAL_SIZE_FONT;
    aHUD.contentColor = [UIColor whiteColor];
    return aHUD;
}

+ (void)hideLoading {
    [self hideLoadingAfterDelay:0];
}

+ (void)hideLoadingAfterDelay:(NSTimeInterval)afterDelay {
    if (progressHUD) {
        [progressHUD hideAnimated:YES afterDelay:afterDelay];
        progressHUD = nil;
    }
}

@end
