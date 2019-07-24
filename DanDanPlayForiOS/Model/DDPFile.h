//
//  DDPFile.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "TOSMBSessionFile+Tools.h"

@class DDPVideoModel;

typedef NS_ENUM(NSUInteger, DDPFileType) {
    DDPFileTypeUnknow,
    DDPFileTypeDocument,
    DDPFileTypeFolder,
};


@interface DDPFile : DDPBase
@property (assign, nonatomic) DDPFileType type;
@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic, readonly) DDPVideoModel *videoModel;
- (instancetype)initWithFileURL:(NSURL *)fileURL type:(DDPFileType)type;

@property (strong, nonatomic) NSMutableArray <__kindof DDPFile *>*subFiles;
@property (weak, nonatomic) __kindof DDPFile *parentFile;
- (void)removeFromParentFile;
@end
