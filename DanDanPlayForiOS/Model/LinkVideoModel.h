//
//  LinkVideoModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "VideoModel.h"

@interface LinkVideoModel : VideoModel
- (instancetype)initWithName:(NSString *)name
                     fileURL:(NSURL *)fileURL
                           hash:(NSString *)hash
                         length:(NSUInteger)length;
@end
