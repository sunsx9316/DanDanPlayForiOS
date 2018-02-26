//
//  DDPCollectionCache+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCollectionCache.h"
#import <WCDB/WCDB.h>

@interface DDPCollectionCache (DB)<WCTTableCoding>

WCDB_PROPERTY(cacheType)
WCDB_PROPERTY(filePath)

@end
