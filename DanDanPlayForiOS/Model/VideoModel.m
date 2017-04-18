//
//  VideoModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel
{
    NSString *_fileName;
    NSURL *_fileURL;
    NSString *_md5;
    NSUInteger _length;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [super init]) {
        _fileURL = fileURL;
    }
    return self;
}

- (NSString *)fileName {
    if (_fileName == nil) {
        _fileName = [[_fileURL.path lastPathComponent] stringByDeletingPathExtension];
    }
    return _fileName;
}


- (NSURL *)fileURL {
    return _fileURL;
}

- (NSString *)md5 {
    if (_md5 == nil) {
        _md5 = [[[NSFileHandle fileHandleForReadingFromURL:_fileURL error:nil] readDataOfLength: 16777216] md5String];
    }
    return _md5;
}

- (NSUInteger)length {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:_fileURL.path error:nil] fileSize];
}
@end
