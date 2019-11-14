//
//  DDPSMBInfo+WCDB.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/28.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSMBInfo+WCDB.h"

@implementation DDPSMBInfo (DB)
WCDB_IMPLEMENTATION(DDPSMBInfo)

WCDB_SYNTHESIZE(DDPSMBInfo, hostName)
WCDB_SYNTHESIZE(DDPSMBInfo, ipAddress)
WCDB_SYNTHESIZE(DDPSMBInfo, userName)
WCDB_SYNTHESIZE(DDPSMBInfo, password)
WCDB_SYNTHESIZE(DDPSMBInfo, workGroup)

WCDB_MULTI_PRIMARY(DDPSMBInfo, "ddp_m_p", hostName)
WCDB_MULTI_PRIMARY(DDPSMBInfo, "ddp_m_p", userName)
WCDB_MULTI_PRIMARY(DDPSMBInfo, "ddp_m_p", password)
@end
