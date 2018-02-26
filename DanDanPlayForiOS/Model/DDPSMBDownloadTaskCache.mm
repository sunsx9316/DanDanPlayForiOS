//
//  DDPSMBDownloadTaskCache.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSMBDownloadTaskCache.h"

@implementation DDPSMBDownloadTaskCache

WCDB_IMPLEMENTATION(DDPSMBDownloadTaskCache)
WCDB_SYNTHESIZE(DDPSMBDownloadTaskCache, sourceFilePath)
WCDB_SYNTHESIZE(DDPSMBDownloadTaskCache, countOfBytesExpectedToReceive)

@end
