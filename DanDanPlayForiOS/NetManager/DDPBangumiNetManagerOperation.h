//
//  DDPBangumiNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//  新番相关接口

#import <Foundation/Foundation.h>
#import "DDPNewBangumiIntroCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPBangumiNetManagerOperation : NSObject

+ (NSURLSessionDataTask *)seasonListWithYear:(NSInteger)year
                                       month:(NSInteger)month
                            completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPNewBangumiIntroCollection))completionHandler;

@end

NS_ASSUME_NONNULL_END
