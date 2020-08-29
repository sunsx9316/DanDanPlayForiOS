//
//  DDPWebDAVFile.m
//  DDPlay
//
//  Created by JimHuang on 2020/4/26.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVFile.h"
#import "DDPWebDAVVideoModel.h"

@implementation DDPWebDAVFile {
    DDPWebDAVVideoModel *_videoModel;
}

- (DDPVideoModel *)videoModel {
    if (_videoModel == nil) {
        _videoModel = [[DDPWebDAVVideoModel alloc] initWithFileURL:self.fileURL];
        _videoModel.file = self;
    }
    return _videoModel;
}

@end
