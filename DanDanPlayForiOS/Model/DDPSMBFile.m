//
//  DDPSMBFile.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSMBFile.h"
#import "DDPSMBVideoModel.h"

@interface DDPSMBFile ()
@property (strong, nonatomic, readwrite) TOSMBSessionFile *sessionFile;
@end

@implementation DDPSMBFile
{
    DDPSMBVideoModel *_videoModel;
    TOSMBSessionFile *_sessionFile;
}

- (instancetype)initWithSMBSessionFile:(TOSMBSessionFile *)file {
    if (self = [super initWithFileURL:file.fullURL type:file.directory ? DDPFileTypeFolder : DDPFileTypeDocument]) {
        _sessionFile = file;
    }
    return self;
}

- (NSString *)name {
    return _sessionFile.name;
}

- (NSURL *)relativeURL {
    if (_relativeURL == nil) {
        _relativeURL = [NSURL URLWithString:[_sessionFile.filePath stringByURLEncode]];
    }
    return _relativeURL;
}

- (DDPVideoModel *)videoModel {
#if !DDPAPPTYPEISMAC
    if (_videoModel == nil) {
        _videoModel = [[DDPSMBVideoModel alloc] initWithFileURL:self.fileURL];
        _videoModel.file = self;
    }
    return _videoModel;
#else
    return nil;
#endif
}

- (TOSMBSessionFile *)sessionFile {
    return _sessionFile;
}

@end
