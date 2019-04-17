//
//  DDPLinkInfo.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPLinkInfo : DDPBase
/*
 name -> machineName
 */

@property (copy, nonatomic) NSArray <NSString *>*ipAdress;
@property (assign, nonatomic) NSUInteger port;
@property (copy, nonatomic) NSString *currentUser;
#pragma mark - 自定义属性
/*
 选择的ip
 */
@property (copy, nonatomic) NSString *selectedIpAdress;
@property (assign, nonatomic) UInt64 saveTime;
//api秘钥
@property (copy, nonatomic) NSString *apiToken;
@end
