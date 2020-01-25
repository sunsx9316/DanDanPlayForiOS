//
//  DDPFilter+DB.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPFilter+DB.h"

@implementation DDPFilter (DB)

WCDB_IMPLEMENTATION(DDPFilter)

WCDB_SYNTHESIZE(DDPFilter, name)
WCDB_SYNTHESIZE(DDPFilter, isRegex)
WCDB_SYNTHESIZE(DDPFilter, content)
WCDB_SYNTHESIZE(DDPFilter, enable)
WCDB_SYNTHESIZE(DDPFilter, cloudRule)



WCDB_PRIMARY(DDPFilter, name)

@end
