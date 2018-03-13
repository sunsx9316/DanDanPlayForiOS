//
//  DDPLinkVideoModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkVideoModel.h"

@implementation DDPLinkVideoModel
{
    NSString *_fileHash;
    NSString *_name;
    NSUInteger _length;
}

- (instancetype)initWithName:(NSString *)name
                     fileURL:(NSURL *)fileURL
                        hash:(NSString *)hash
                      length:(NSUInteger)length {
    if (self = [super initWithFileURL:fileURL]) {
        _fileHash = hash;
        _length = length;
        _name = name;
    }
    return self;
}

- (NSString *)fileHash {
    return _fileHash;
}

- (NSUInteger)length {
    return _length;
}

- (NSString *)name {
    return _name;
}

- (BOOL)isCacheHash {
    return _fileHash != nil;
}

@end
