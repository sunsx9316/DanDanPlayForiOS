//
//  UIView+Toast.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/2/20.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "UIView+Toast.h"

@implementation UIView (Toast)
- (void)showWithText:(NSString *)text {
    [self showWithText:text offset:CGPointZero];
}

- (void)showWithText:(NSString *)text offset:(CGPoint)offset {
    [self showWithText:text offset:offset hideAfterDelay:1.3];
}

- (void)showWithText:(NSString *)text
      hideAfterDelay:(NSTimeInterval)afterDelay {
    [self showWithText:text offset:CGPointZero hideAfterDelay:afterDelay];
}

- (void)showWithText:(NSString *)text
              offset:(CGPoint)offset
      hideAfterDelay:(NSTimeInterval)afterDelay {
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeText InView:self];
    hud.label.text = text;
    hud.label.numberOfLines = 0;
    hud.offset = offset;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

- (void)showWithError:(NSError *)error {
    [self showWithError:error userInfoKey:NSLocalizedDescriptionKey];
}

- (void)showWithError:(NSError *)error
          userInfoKey:(NSString *)userInfoKey {
    NSString *errStr = [NSString stringWithFormat:@"%@", error.userInfo[userInfoKey]];
    if (errStr.length == 0) {
        errStr = error.domain;
    }
    
    [self showWithText:errStr];
}

- (void)showLoading {
    [self showLoadingWithText:nil];
}

- (void)showLoadingWithText:(NSString *)text {
//    if (!text.length) text = @"加载中...";
    
    [self hideLoading];
    
    MBProgressHUD *progressHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeIndeterminate InView:self];
    progressHUD.tag = 'pHUD';
    progressHUD.label.text = text;
    [progressHUD showAnimated:YES];
}

- (void)hideLoading {
    [self hideLoadingAfterDelay:0];
}

- (void)hideLoadingAfterDelay:(NSTimeInterval)afterDelay {
    MBProgressHUD *progressHUD = [self viewWithTag:'pHUD'];
    [progressHUD hideAnimated:YES afterDelay:afterDelay];
}

- (void)hideAllHUD {
    [MBProgressHUD hideHUDForView:self animated:YES];
}

@end
