//
//  DDPBaseViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationItem+Tools.h"
/**
 *  基类
 */
@interface DDPBaseViewController : UIViewController
- (void)configLeftItem;
- (void)configRightItem;
- (void)touchLeftItem:(UIButton *)button;

- (Class)ddp_navigationBarClass;


/**
 检测用户登录状态 没登录则弹出登录窗口

 @return 用户是否登录
 */
- (BOOL)showLoginAlert;

/**
 检测用户登录状态

 @param action 确认之后的事件
 @return 用户是否登录
 */
- (BOOL)showLoginAlertWithAction:(void(^)(void))action;
@end
