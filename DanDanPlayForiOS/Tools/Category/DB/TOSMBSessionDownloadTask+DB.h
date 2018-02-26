//
//  TOSMBSessionDownloadTask+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <TOSMBClient/TOSMBClient.h>
#import "TOSMBSessionDownloadTask+Tools.h"
#import "DDPSMBDownloadTaskCache.h"

@interface TOSMBSessionDownloadTask (DB)
@property (strong, nonatomic, readonly) DDPSMBDownloadTaskCache *cache;

+ (instancetype)taskWithCache:(DDPSMBDownloadTaskCache *)cache;


@end
