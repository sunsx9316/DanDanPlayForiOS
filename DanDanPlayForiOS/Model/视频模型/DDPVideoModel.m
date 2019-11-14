//
//  DDPVideoModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPVideoModel.h"

@implementation DDPVideoModel {
    NSString *_fileName;
    NSString *_fileNameWithPathExtension;
    NSURL *_fileURL;
    NSString *_fileHash;
    NSUInteger _length;
    NSString *_quickHash;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [super init]) {
        _fileURL = fileURL;
    }
    return self;
}

- (NSString *)name {
    if (_fileName == nil) {
        _fileName = [[[_fileURL.path lastPathComponent] stringByDeletingPathExtension] stringByURLDecode];
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

- (NSString *)fileHash {
    if (_fileHash == nil) {
        _fileHash = [[[NSFileHandle fileHandleForReadingFromURL:_fileURL error:nil] readDataOfLength: MEDIA_MATCH_LENGTH] md5String];
    }
    return _fileHash;
}

- (NSUInteger)length {
    return (NSUInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:_fileURL.path error:nil] fileSize];
}

- (NSString *)quickHash {
    if (_quickHash == nil) {
        _quickHash = [[NSString stringWithFormat:@"%@%lu", self.fileNameWithPathExtension, (unsigned long)self.length] md5String];
    }
    return _quickHash;
}

+ (NSArray<NSString *> *)modelPropertyWhitelist {
    return @[@"fileURL"];
}

- (NSUInteger)hash {
    return self.fileURL.hash;
}

- (BOOL)isCacheHash {
    return _fileHash != nil;
}

- (BOOL)isEqual:(DDPVideoModel *)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    return [self.fileURL isEqual:object.fileURL];
}

#pragma mark - DDPMediaItemProtocol
- (NSURL *)url {
    return self.fileURL;
}

- (NSDictionary *)mediaOptions {
    return nil;
}

@end
