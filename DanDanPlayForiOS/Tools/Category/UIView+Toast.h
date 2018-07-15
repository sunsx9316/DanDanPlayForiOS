//
//  UIView+Toast.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/2/20.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD+Tools.h"

@interface UIView (Toast)
/**
 *  只显示文字
 *
 *  @param text 文字
 */
- (void)showWithText:(NSString *)text;

/**
 只显示文字

 @param text 文字
 @param offset 偏移
 */
- (void)showWithText:(NSString *)text offset:(CGPoint)offset;

/**
 只显示文字
 
 @param text 文字
 @param afterDelay 多少秒之后隐藏
 */
- (void)showWithText:(NSString *)text 
      hideAfterDelay:(NSTimeInterval)afterDelay;

/**
 只显示文字

 @param text 文字
 @param offset 偏移
 @param afterDelay 在多少秒之后隐藏
 */
- (void)showWithText:(NSString *)text
              offset:(CGPoint)offset
      hideAfterDelay:(NSTimeInterval)afterDelay;

/**
 *  显示错误信息
 *
 *  @param error 错误
 */
- (void)showWithError:(NSError *)error;


/**
 显示错误信息

 @param error 错误
 @param userInfoKey userInfoKey
 */
- (void)showWithError:(NSError *)error
          userInfoKey:(NSString *)userInfoKey;


/**
 加载loading
 */
- (void)showLoading;

/**
 *  显示一个一直显示的hud面板
 *
 *  @param text 文字 为nil时为加载中
 */
- (void)showLoadingWithText:(NSString *)text;


/**
 *  隐藏一直显示的hud面板
 */
- (void)hideLoading;


/**
 隐藏一直显示的hud面板

 @param afterDelay 在afterDelay秒后
 */
- (void)hideLoadingAfterDelay:(NSTimeInterval)afterDelay;

/**
 隐藏所有HUD
 */
- (void)hideAllHUD;
@end
