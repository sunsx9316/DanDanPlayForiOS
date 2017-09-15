//
//  JHLinkFile.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHLinkFile.h"

@implementation JHLinkFile
{
    LinkVideoModel *_videoModel;
}

- (instancetype)initWithLibraryFile:(JHLibrary *)file {
    if (self = [super initWithFileURL:nil type:file.fileType]) {
        _library = file;
    }
    return self;
}

- (NSString *)name {
    return _library.name;
}

- (NSURL *)fileURL {
    if (_library.fileType == JHFileTypeFolder) {
        return [NSURL URLWithString:[_library.path stringByURLEncode]];
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/stream/%@", [CacheManager shareCacheManager].linkInfo.selectedIpAdress, LINK_API_INDEX, _library.md5]];
}

- (VideoModel *)videoModel {
    if (_videoModel == nil) {
        _videoModel = [[LinkVideoModel alloc] initWithName:self.name fileURL:self.fileURL hash:_library.md5 length:_library.size];
        _videoModel.file = self;
    }
    return _videoModel;
}

@end
