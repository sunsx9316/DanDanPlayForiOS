//
//  DDPFilter+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPFilter.h"
#import <WCDB/WCDB.h>

@interface DDPFilter (DB)<WCTTableCoding>
WCDB_PROPERTY(name)
WCDB_PROPERTY(isRegex)
WCDB_PROPERTY(content)
WCDB_PROPERTY(enable)
WCDB_PROPERTY(cloudRule)
@end
