//
//  DDPLinkWelcome.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPLinkWelcome : DDPBase
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *time;
//是否需要密码
@property (assign, nonatomic) BOOL tokenRequired;
@end
