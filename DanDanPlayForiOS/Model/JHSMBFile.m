//
//  JHSMBFile.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHSMBFile.h"
#import "SMBVideoModel.h"

@implementation JHSMBFile
{
    SMBVideoModel *_videoModel;
    TOSMBSessionFile *_sessionFile;
    NSString *_quickHash;
}

- (instancetype)initWithSMBSessionFile:(TOSMBSessionFile *)file {
    if (self = [super initWithFileURL:file.fullURL type:file.directory ? JHFileTypeFolder : JHFileTypeDocument]) {
        _sessionFile = file;
    }
    return self;
}

- (NSString *)name {
    return _sessionFile.name;
}

- (NSURL *)relativeURL {
    return [NSURL URLWithString:[_sessionFile.filePath stringByURLEncode]];
}

- (VideoModel *)videoModel {
    if (_videoModel == nil) {
        _videoModel = [[SMBVideoModel alloc] initWithFileURL:self.fileURL];
        _videoModel.file = self;
    }
    return _videoModel;
}

- (TOSMBSessionFile *)sessionFile {
    return _sessionFile;
}

@end
