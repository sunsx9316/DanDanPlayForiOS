//
//  JHSMBInfo.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  smb登录对象

#import "JHBase.h"

@interface JHSMBInfo : JHBase
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) NSString *ipAddress;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@end
