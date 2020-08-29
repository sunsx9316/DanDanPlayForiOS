//
//  DDPWebDAVInputStream.h
//  DDPlay
//
//  Created by JimHuang on 2020/5/30.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DDPWebDAVInputStream;
@protocol DDPWebDAVInputStreamDelegate <NSStreamDelegate>
@optional
- (void)inputStream:(DDPWebDAVInputStream *)stream downloadProgress:(CGFloat)downloadProgress;

@end

@interface DDPWebDAVInputStream : NSInputStream
@property (nonatomic, strong, readonly) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url fileLength:(NSInteger)fileLength;
@end

NS_ASSUME_NONNULL_END
