//
//  DDPUpdateNetManagerOperation.h
//  DDPlay_ToMac
//
//  Created by JimHuang on 2019/9/26.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPVersion.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPUpdateNetManagerOperation : NSObject

+ (NSURLSessionDataTask *)checkUpdateInfoWithCompletionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPVersion))completionHandler;

+ (NSURLSessionTask *)downloadLatestAppWithURL:(NSURL *)url
                                          progressHandler:(void (^)(NSProgress *downloadProgress))progressHandler
                                 completionHandler:(DDP_ENTITY_RESPONSE_ACTION(NSURL))completionHandler;

@end

NS_ASSUME_NONNULL_END
