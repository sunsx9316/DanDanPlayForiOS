//
//  DDPRegisterRequest.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPRegisterRequest : DDPBase
/*
 name -> ScreenName
 */
 
@property (copy, nonatomic) NSString *account;
@property (copy, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;


/**
 第三方登录账号的UserId
 */
@property (copy, nonatomic) NSString *userId;

/**
 第三方账号的Token
 */
@property (copy, nonatomic) NSString *token;
@end
