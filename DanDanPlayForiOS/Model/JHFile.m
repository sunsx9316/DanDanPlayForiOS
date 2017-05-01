//
//  JHFile.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFile.h"

@implementation JHFile
{
    VideoModel *_videoModel;
}

- (VideoModel *)videoModel {
    if (_videoModel == nil) {
        _videoModel = [[VideoModel alloc] initWithFileURL:self.fileURL];
        _videoModel.file = self;
    }
    return _videoModel;
}

- (NSUInteger)hash {
    return self.fileURL.hash;
}

- (BOOL)isEqual:(JHFile *)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    return [self.fileURL isEqual:object.fileURL];
}

@end
