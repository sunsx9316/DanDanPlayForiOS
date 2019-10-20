//
//  DDPSMBVideoModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSMBVideoModel.h"
#import <MobileVLCKit/MobileVLCKit.h>

@implementation DDPSMBVideoModel
{
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

//- (VLCMedia *)media {
//    VLCMedia *media = [super media];
//    TOSMBSession *session = [DDPToolsManager shareToolsManager].SMBSession;
//    [media setMetadata:<#(nonnull NSString *)#> forKey:<#(nonnull NSString *)#>]
//    return media;
//}

@end
