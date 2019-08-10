//
//  DDPLinkFile.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkFile.h"

#if !DDPAPPTYPEISMAC
#import "DDPLinkVideoModel.h"
#endif

@implementation DDPLinkFile
#if !DDPAPPTYPEISMAC
{
    DDPLinkVideoModel *_videoModel;
}
#endif

- (instancetype)initWithLibraryFile:(DDPLibrary *)file {
    if (self = [super initWithFileURL:nil type:file.fileType]) {
        _library = file;
    }
    return self;
}

- (NSString *)name {
    return _library.name;
}

- (NSURL *)fileURL {
    if (_library.fileType == DDPFileTypeFolder) {
        return [NSURL URLWithString:[_library.path stringByURLEncode]];
    }
    
    return ddp_linkVideoURL([DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress, _library.playId);
}

- (DDPVideoModel *)videoModel {
#if !DDPAPPTYPEISMAC
    if (_videoModel == nil) {
        _videoModel = [[DDPLinkVideoModel alloc] initWithName:self.name fileURL:self.fileURL hash:_library.md5 length:_library.size];
        _videoModel.file = self;
    }
    return _videoModel;
#else
    return nil;
#endif
}

@end
