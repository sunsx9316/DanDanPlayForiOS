//
//  DDPCacheManager+DB.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCacheManager+DB.h"
#import "DDPFilter.h"
#import "DDPVideoCache.h"
#import "DDPSMBFileHashCache.h"
#import "DDPCollectionCache.h"
#import "DDPLinkInfo.h"
#import "DDPSMBDownloadTaskCache.h"
#import "DDPUser+WCTTableCoding.h"

@implementation DDPCacheManager (DB)

+ (WCTDatabase *)shareDB {
    static WCTDatabase *_database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _database = [[WCTDatabase alloc] initWithPath:[[UIApplication sharedApplication].documentsPath stringByAppendingPathComponent:@"DDPConfig.db"]];
        [_database createTableAndIndexesOfName:DDPFilter.className withClass:DDPFilter.class];
        [_database createTableAndIndexesOfName:DDPVideoCache.className withClass:DDPVideoCache.class];
        [_database createTableAndIndexesOfName:DDPSMBFileHashCache.className withClass:DDPSMBFileHashCache.class];
        [_database createTableAndIndexesOfName:DDPCollectionCache.className withClass:DDPCollectionCache.class];
        [_database createTableAndIndexesOfName:DDPLinkInfo.className withClass:DDPLinkInfo.class];
        [_database createTableAndIndexesOfName:DDPSMBInfo.className withClass:DDPSMBInfo.class];
        [_database createTableAndIndexesOfName:DDPUser.className withClass:DDPUser.class];
        
#if !DDPAPPTYPE
        [_database createTableAndIndexesOfName:DDPSMBDownloadTaskCache.className withClass:DDPSMBDownloadTaskCache.class];
        [_database createTableAndIndexesOfName:DDPLinkDownloadTask.className withClass:DDPLinkDownloadTask.class];
#endif
    });
    return _database;
}

@end
