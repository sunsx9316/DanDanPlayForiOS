//
//  DDPSMBInfo+WCDB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/28.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSMBInfo.h"
#import <WCDB/WCDB.h>

@interface DDPSMBInfo (DB)<WCTTableCoding>

WCDB_PROPERTY(hostName)
WCDB_PROPERTY(ipAddress)
WCDB_PROPERTY(userName)
WCDB_PROPERTY(password)
WCDB_PROPERTY(workGroup)

@end
