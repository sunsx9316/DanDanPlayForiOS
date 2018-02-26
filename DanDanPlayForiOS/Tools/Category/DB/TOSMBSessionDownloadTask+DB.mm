//
//  TOSMBSessionDownloadTask+DB.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "TOSMBSessionDownloadTask+DB.h"

@implementation TOSMBSessionDownloadTask (DB)

+ (instancetype)taskWithCache:(DDPSMBDownloadTaskCache *)cache {
    TOSMBSession *SMBSession = [DDPToolsManager shareToolsManager].SMBSession;
    if (SMBSession) {
        NSString *downloadPath = ddp_taskDownloadPath();
        TOSMBSessionDownloadTask *aTask = [SMBSession downloadTaskForFileAtPath:cache.sourceFilePath destinationPath:downloadPath delegate:nil];
        //设置文件大小
        [aTask setValue:@(cache.countOfBytesExpectedToReceive) forKey:@"countOfBytesExpectedToReceive"];
        return aTask;
    }
    return nil;
}

- (DDPSMBDownloadTaskCache *)cache {
    DDPSMBDownloadTaskCache *_cache = objc_getAssociatedObject(self, _cmd);
    if (_cache == nil) {
        _cache = [[DDPSMBDownloadTaskCache alloc] init];
        _cache.sourceFilePath = self.sourceFilePath;
        _cache.countOfBytesExpectedToReceive = self.countOfBytesExpectedToReceive;
    }
    return _cache;
}

@end
