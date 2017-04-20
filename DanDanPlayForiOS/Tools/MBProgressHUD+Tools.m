//
//  MBProgressHUD+Tools.m
//  Fumuzhihui
//
//  Created by JimHuang on 16/5/11.
//  Copyright © 2016年 aiitec. All rights reserved.
//

#import "MBProgressHUD+Tools.h"

static MBProgressHUD *progressHUD = nil;

@implementation MBProgressHUD (Tools)
+ (void)showWithText:(NSString *)text {
    [self showWithText:text atView:nil];
}

+ (void)showWithText:(NSString *)text atView:(UIView *)view {
    UIView *parentView = [UIApplication sharedApplication].keyWindow;
    if (!parentView) return;
    
    [MBProgressHUD hideHUDForView:parentView animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:1];
}

+ (void)showWithError:(NSError *)error {
    [self showWithText:error.domain atView:nil];
}

+ (void)showIndeterminateHUDWithView:(UIView *)view text:(NSString *)text {
    if (!text.length) text = @"加载中...";
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    [self hideIndeterminateHUD];
    
    progressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    progressHUD.mode = MBProgressHUDModeIndeterminate;
    progressHUD.label.text = text;
}

+ (void)hideIndeterminateHUD {
    if (progressHUD) {
        [progressHUD hideAnimated:YES];
    }
}
@end
