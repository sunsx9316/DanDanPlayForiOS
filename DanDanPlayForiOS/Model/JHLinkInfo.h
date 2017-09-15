//
//  JHLinkInfo.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHLinkInfo : JHBase
/*
 name -> machineName
 */

@property (copy, nonatomic) NSArray <NSString *>*ipAdress;
/*
 选择的ip
 */
@property (copy, nonatomic) NSString *selectedIpAdress;
@property (assign, nonatomic) NSUInteger port;
@property (copy, nonatomic) NSString *currentUser;
@end
