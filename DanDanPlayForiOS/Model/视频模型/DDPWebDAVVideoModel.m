//
//  DDPWebDAVVideoModel.m
//  DDPlay
//
//  Created by JimHuang on 2020/4/26.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVVideoModel.h"

@implementation DDPWebDAVVideoModel {
    NSString *_fileHash;
    NSUInteger _length;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL
                           hash:(NSString *)hash
                         length:(NSUInteger)length {
    if (self = [super initWithFileURL:fileURL]) {
        _fileHash = hash;
        _length = length;
    }
    return self;
}

- (NSString *)fileHash {
    return _fileHash;
}

- (NSUInteger)length {
    return _length;
}

- (BOOL)isCacheHash {
    return _fileHash != nil;
}

- (NSDictionary *)mediaOptions {
    return @{@"isWebDav" : @(YES), @"fileSize" : @(self.length)};
}

@end
