//
//  DDPVideoCache.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPVideoCache.h"
#import "DDPVideoCache+DB.h"

@implementation DDPVideoCache

WCDB_IMPLEMENTATION(DDPVideoCache)

WCDB_SYNTHESIZE(DDPVideoCache, name)
WCDB_SYNTHESIZE(DDPVideoCache, identity)
WCDB_SYNTHESIZE(DDPVideoCache, fileHash)
WCDB_SYNTHESIZE(DDPVideoCache, lastPlayTime)

WCDB_PRIMARY(DDPVideoCache, fileHash)

@end
