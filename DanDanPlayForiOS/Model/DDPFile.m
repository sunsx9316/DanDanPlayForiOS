//
//  DDPFile.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFile.h"

@implementation DDPFile {
    DDPVideoModel *_videoModel;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL type:(DDPFileType)type {
    if (self = [super init]) {
        _fileURL = fileURL;
        _type = type;
    }
    return self;
}

- (NSString *)name {
    return self.fileURL.lastPathComponent;
}

- (DDPVideoModel *)videoModel {
    if (_videoModel == nil) {
        _videoModel = [[DDPVideoModel alloc] initWithFileURL:self.fileURL];
        _videoModel.file = self;
    }
    return _videoModel;
}

- (NSMutableArray<DDPFile *> *)subFiles {
    if (_subFiles == nil) {
        _subFiles = [NSMutableArray array];
    }
    return _subFiles;
}

- (void)removeFromParentFile {
    NSMutableDictionary <NSString *, NSMutableArray <NSString *>*>*folderCache = (NSMutableDictionary <NSString *, NSMutableArray <NSString *>*> *)[DDPCacheManager shareCacheManager].folderCache;
    //从自定义文件夹缓存移除
    [folderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeObject:self.videoModel.quickHash];
    }];
    
    [DDPCacheManager shareCacheManager].folderCache = folderCache;
    
    [self.parentFile.subFiles removeObject:self];
}

- (NSUInteger)hash {
    return self.fileURL.hash;
}

- (BOOL)isEqual:(DDPFile *)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    return [self.fileURL isEqual:object.fileURL];
}

@end
