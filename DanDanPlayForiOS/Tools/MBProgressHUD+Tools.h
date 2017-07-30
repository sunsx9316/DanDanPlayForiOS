//
//  MBProgressHUD+Tools.h
//  Fumuzhihui
//
//  Created by JimHuang on 16/5/11.
//  Copyright © 2016年 aiitec. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (Tools)

/**
 *  只显示文字
 *
 *  @param text 文字
 */
+ (void)showWithText:(NSString *)text;

/**
 *  只显示文字
 *
 *  @param text       文字
 *  @param parentView 父视图
 */
+ (void)showWithText:(NSString *)text atView:(UIView *)view;

/**
 只显示文字
 
 @param text 文字
 @param view 父视图
 @param afterDelay 多少秒之后隐藏
 */
+ (void)showWithText:(NSString *)text
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)afterDelay;

/**
 *  显示错误信息
 *
 *  @param error 错误
 */
+ (void)showWithError:(NSError *)error;

/**
 *  显示一个一直显示的hud面板
 *
 *  @param view 父view 为nil时为windows
 *  @param text 文字 为nil时为加载中
 */
+ (void)showLoadingInView:(UIView *)view text:(NSString *)text;

/**
 默认样式的hud

 @param mode 显示样式
 @param view 父view
 @return hud
 */
+ (instancetype)defaultTypeHUDWithMode:(MBProgressHUDMode)mode InView:(UIView *)view;

/**
 *  隐藏一直显示的hud面板
 */
+ (void)hideLoading;
@end
