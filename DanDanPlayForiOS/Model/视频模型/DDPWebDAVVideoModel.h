//
//  DDPWebDAVVideoModel.h
//  DDPlay
//
//  Created by JimHuang on 2020/4/26.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPWebDAVVideoModel : DDPVideoModel
- (instancetype)initWithFileURL:(NSURL *)fileURL
                           hash:(NSString *)hash
                         length:(NSUInteger)length;
@end

NS_ASSUME_NONNULL_END
