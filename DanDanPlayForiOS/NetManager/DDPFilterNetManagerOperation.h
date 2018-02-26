//
//  DDPFilterNetManagerOperation.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/2/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPFilterCollection.h"

@interface DDPFilterNetManagerOperation : NSObject
/**
 *  获取云过滤列表
 *
 *  @param completionHandler 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)cloudFilterListWithCompletionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPFilterCollection))completionHandler;
@end
