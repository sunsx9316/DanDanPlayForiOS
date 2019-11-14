//
//  DDPSMBInfo.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  smb登录对象

#import "DDPBase.h"

@interface DDPSMBInfo : DDPBase
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) NSString *ipAddress;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *workGroup;
@end
