//
//  DDPSMBDownloadTaskCache.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPDownloadTaskProtocol.h"
#import <WCDB/WCDB.h>

@interface DDPSMBDownloadTaskCache : DDPBase<WCTTableCoding>
@property (copy, nonatomic) NSString *sourceFilePath;
@property (assign, nonatomic) int64_t countOfBytesExpectedToReceive;

WCDB_PROPERTY(sourceFilePath)
WCDB_PROPERTY(countOfBytesExpectedToReceive)
@end
