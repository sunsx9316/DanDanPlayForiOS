//
//  DDPSMBVideoModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPVideoModel.h"

@interface DDPSMBVideoModel : DDPVideoModel
- (instancetype)initWithFileURL:(NSURL *)fileURL
                           hash:(NSString *)hash
                         length:(NSUInteger)length;
@end
