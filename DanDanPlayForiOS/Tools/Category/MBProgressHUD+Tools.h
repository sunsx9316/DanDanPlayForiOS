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
 默认样式的hud

 @param mode 显示样式
 @param view 父view
 @return hud
 */
+ (instancetype)defaultTypeHUDWithMode:(MBProgressHUDMode)mode InView:(UIView *)view;

@end
