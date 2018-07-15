//
//  DDPRegisterResult.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/6/14.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPRegisterResult : DDPBase
/*
 identity -> UserId
 */

@property (copy, nonatomic) NSString *token;
@end
