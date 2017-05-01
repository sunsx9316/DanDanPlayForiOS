//
//  JHFile.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

typedef NS_ENUM(NSUInteger, JHFileType) {
    JHFileTypeUnknow,
    JHFileTypeDocument,
    JHFileTypeFolder,
};

//@class VideoModel;
@interface JHFile : JHBase
//@property (assign, nonatomic) BOOL isParse;
@property (assign, nonatomic) JHFileType type;
@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic) NSMutableArray <JHFile *>*subFiles;
@property (weak, nonatomic) JHFile *parentFile;
@property (strong, nonatomic, readonly) VideoModel *videoModel;
@end
