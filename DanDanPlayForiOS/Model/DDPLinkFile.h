//
//  DDPLinkFile.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFile.h"

@interface DDPLinkFile : DDPFile
@property (strong, nonatomic, readonly) DDPLibrary *library;
- (instancetype)initWithLibraryFile:(DDPLibrary *)file;
@end
