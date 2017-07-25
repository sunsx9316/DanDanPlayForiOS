//
//  JHSMBFile.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFile.h"

@interface JHSMBFile : JHFile
/**
 name 包含拓展名
 */

@property (strong, nonatomic, readonly) TOSMBSessionFile *sessionFile;

/**
 相对路径
 */
@property (strong, nonatomic, readonly) NSURL *relativeURL;
- (instancetype)initWithSMBSessionFile:(TOSMBSessionFile *)file;
@end
