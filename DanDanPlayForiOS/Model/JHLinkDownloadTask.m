//
//  JHLinkDownloadTask.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHLinkDownloadTask.h"

@implementation JHLinkDownloadTask

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name" : @"Title",
             @"taskId" : @"Id",
             @"progress" : @"Progress",
             @"state" : @"State",
             @"totalBytes" : @"TotalBytes",
             @"downloadedBytes" : @"DownloadedBytes",
             @"downloadSpeed" : @"DownloadSpeed",
             @"uploadSpeed" : @"UploadSpeed",
             @"remainTime" : @"RemainTime",
             @"savePath" : @"SavePath",
             @"ignore" : @"Ignore",
             @"createdTime" : @"CreatedTime"};
}

@end
