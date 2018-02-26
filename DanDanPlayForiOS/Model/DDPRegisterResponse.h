//
//  DDPRegisterResponse.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPErrorProtocol.h"

@interface DDPRegisterResponse : DDPBase<DDPErrorProtocol>
/*
 identity -> UserId
 */

@property (copy, nonatomic) NSString *token;

@end
