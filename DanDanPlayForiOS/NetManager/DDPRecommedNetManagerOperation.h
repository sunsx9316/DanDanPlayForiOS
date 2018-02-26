//
//  DDPRecommedNetManagerOperation.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/3/11.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPHomePage.h"


@interface DDPRecommedNetManagerOperation : NSObject
/**
 *  获取首页推荐信息
 *
 *  @param complete 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)recommedInfoWithCompletionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPHomePage))completionHandler;
@end
