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
    NSString *_md5;
    NSString *_name;
    NSUInteger _length;
}

- (instancetype)initWithName:(NSString *)name
                     fileURL:(NSURL *)fileURL
                        hash:(NSString *)hash
                      length:(NSUInteger)length {
    if (self = [super initWithFileURL:fileURL]) {
        _md5 = hash;
        _length = length;
        _name = name;
    }
    return self;
}

- (NSString *)md5 {
    return _md5;
}

- (NSUInteger)length {
    return _length;
}

- (NSString *)name {
    return _name;
}

@end
