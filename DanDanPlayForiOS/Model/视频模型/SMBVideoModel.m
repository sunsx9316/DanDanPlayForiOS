//
//  SMBVideoModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBVideoModel.h"

@implementation SMBVideoModel
{
    NSString *_md5;
    NSUInteger _length;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL
                           hash:(NSString *)hash
                         length:(NSUInteger)length {
    if (self = [super initWithFileURL:fileURL]) {
        _md5 = hash;
        _length = length;
    }
    return self;
}

- (NSString *)md5 {
    return _md5;
}

- (NSUInteger)length {
    return _length;
}

@end
