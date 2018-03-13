//
//  DDPVideoCache+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPVideoCache.h"
#import <WCDB/WCDB.h>

@interface DDPVideoCache ()<WCTTableCoding>

WCDB_PROPERTY(name)
WCDB_PROPERTY(identity)
WCDB_PROPERTY(fileHash)
WCDB_PROPERTY(lastPlayTime)

@end
