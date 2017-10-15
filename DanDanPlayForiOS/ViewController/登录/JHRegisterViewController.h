//
//  JHRegisterViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  注册

#import "JHBaseViewController.h"

@interface JHRegisterViewController : JHBaseViewController

/**
 registerRequired == NO 则为绑定帐号
 */
@property (strong, nonatomic) JHUser *user;
@end
