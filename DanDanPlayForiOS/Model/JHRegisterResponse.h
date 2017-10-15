//
//  JHRegisterResponse.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"
#import "JHErrorProtocol.h"

@interface JHRegisterResponse : JHBase<JHErrorProtocol>
/*
 identity -> UserId
 */

@property (copy, nonatomic) NSString *token;

@end
