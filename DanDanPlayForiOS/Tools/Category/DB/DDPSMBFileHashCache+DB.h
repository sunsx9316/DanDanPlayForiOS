//
//  DDPSMBFileHashCache+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSMBFileHashCache.h"
#import <WCDB/WCDB.h>

@interface DDPSMBFileHashCache (DB)<WCTTableCoding>

WCDB_PROPERTY(key)
WCDB_PROPERTY(md5)
WCDB_PROPERTY(date)

@end
