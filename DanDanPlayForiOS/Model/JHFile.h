//
//  JHFile.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"
#import "TOSMBSessionFile+Tools.h"

typedef NS_ENUM(NSUInteger, JHFileType) {
    JHFileTypeUnknow,
    JHFileTypeDocument,
    JHFileTypeFolder,
};


@interface JHFile : JHBase
@property (assign, nonatomic) JHFileType type;
@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic, readonly) VideoModel *videoModel;
- (instancetype)initWithFileURL:(NSURL *)fileURL type:(JHFileType)type;

@property (strong, nonatomic) NSMutableArray <__kindof JHFile *>*subFiles;
@property (weak, nonatomic) __kindof JHFile *parentFile;
- (void)removeFromParentFile;
@end
