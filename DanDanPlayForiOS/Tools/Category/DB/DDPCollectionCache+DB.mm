//
//  DDPCollectionCache+DB.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCollectionCache+DB.h"

@implementation DDPCollectionCache (DB)

WCDB_IMPLEMENTATION(DDPCollectionCache)
WCDB_SYNTHESIZE(DDPCollectionCache, cacheType)
WCDB_SYNTHESIZE(DDPCollectionCache, filePath)

WCDB_MULTI_PRIMARY(DDPCollectionCache, "ddp_m_p", cacheType)
WCDB_MULTI_PRIMARY(DDPCollectionCache, "ddp_m_p", filePath)


@end
