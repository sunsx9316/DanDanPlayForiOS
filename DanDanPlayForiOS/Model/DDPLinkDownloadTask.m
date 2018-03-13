//
//  DDPLinkDownloadTask.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkDownloadTask.h"

NSString *DDPLinkDownloadTaskStateTextWaitingForStart = @"WaitingForStart";
NSString *DDPLinkDownloadTaskStateTextDownloading = @"Downloading";
NSString *DDPLinkDownloadTaskStateTextPaused = @"Paused";
NSString *DDPLinkDownloadTaskStateTextSeeding = @"Seeding";
NSString *DDPLinkDownloadTaskStateTextStopping = @"Stopping";
NSString *DDPLinkDownloadTaskStateTextStopped = @"Stopped";
NSString *DDPLinkDownloadTaskStateTextHashing = @"Hashing";
NSString *DDPLinkDownloadTaskStateTextMetadata = @"Metadata";
NSString *DDPLinkDownloadTaskStateTextError = @"Error";

@implementation DDPLinkDownloadTask

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
             @"createdTime" : @"CreatedTime",
             @"isDeleted" : @"IsDeleted"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *state = dic[@"StateText"];
    if ([state isEqualToString:DDPLinkDownloadTaskStateTextWaitingForStart] || [state isEqualToString:DDPLinkDownloadTaskStateTextPaused]) {
        _state = DDPLinkDownloadTaskStatePause;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextDownloading]) {
        _state = DDPLinkDownloadTaskStateDownloading;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextSeeding]) {
        _state = DDPLinkDownloadTaskStateMaskTorrent;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextStopping]) {
        _state = DDPLinkDownloadTaskStateStoping;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextStopped]) {
        _state = DDPLinkDownloadTaskStateStop;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextHashing]) {
        _state = DDPLinkDownloadTaskStateCalculateHash;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextMetadata]) {
        _state = DDPLinkDownloadTaskStateGetMetaData;
    }
    else if ([state isEqualToString:DDPLinkDownloadTaskStateTextError]) {
        _state = DDPLinkDownloadTaskStateError;
    }
    return YES;
}

@end
