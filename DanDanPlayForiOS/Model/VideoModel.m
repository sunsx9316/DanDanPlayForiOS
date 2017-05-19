//
//  VideoModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "VideoModel.h"
#import <MobileVLCKit/VLCMedia.h>

@implementation VideoModel
{
    NSString *_fileName;
    NSString *_fileNameWithPathExtension;
    NSURL *_fileURL;
    NSString *_md5;
    NSUInteger _length;
    NSString *_quickHash;
    VLCMedia *_media;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [super init]) {
        _fileURL = fileURL;
    }
    return self;
}

- (NSString *)name {
    if (_fileName == nil) {
        _fileName = [[_fileURL.path lastPathComponent] stringByDeletingPathExtension];
    }
    return _fileName;
}

- (NSString *)fileNameWithPathExtension {
    if (_fileNameWithPathExtension == nil) {
        _fileNameWithPathExtension = [_fileURL.path lastPathComponent];
    }
    return _fileNameWithPathExtension;
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
    return (NSUInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:_fileURL.path error:nil] fileSize];
}

- (NSString *)quickHash {
    if (_quickHash == nil) {
        _quickHash = [self.fileNameWithPathExtension md5String];
    }
    return _quickHash;
}

- (VLCMedia *)media {
    if (_media == nil) {
        _media = [[VLCMedia alloc] initWithURL:_fileURL];
    }
    return _media;
}

+ (NSArray<NSString *> *)modelPropertyWhitelist {
    return @[@"fileURL"];
}

- (NSUInteger)hash {
    return self.fileURL.hash;
}

- (BOOL)isEqual:(VideoModel *)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    return [self.fileURL isEqual:object.fileURL];
}

@end
