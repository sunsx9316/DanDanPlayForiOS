//
//  DDPCacheManager+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCacheManager.h"
#import <WCDB/WCDB.h>

@interface DDPCacheManager (DB)
+ (WCTDatabase *)shareDB;
@end
