//
//  DDPPlayHistoryNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPBangumiQueueIntroCollection.h"

@interface DDPPlayHistoryNetManagerOperation : NSObject

/**
 获取未看剧集列表的简介

 @param user 用户
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)playHistoryWithUser:(DDPUser *)user
                         completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPBangumiQueueIntroCollection))completionHandler;

/**
 获取未看番剧与剧集的详细数据

 @param user 用户
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)playHistoryDetailWithUser:(DDPUser *)user
                            completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPBangumiQueueIntroCollection))completionHandler;
@end
