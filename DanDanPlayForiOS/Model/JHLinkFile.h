//
//  JHLinkFile.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFile.h"
#import "LinkVideoModel.h"

@interface JHLinkFile : JHFile
@property (strong, nonatomic, readonly) JHLibrary *library;
- (instancetype)initWithLibraryFile:(JHLibrary *)file;
@end
