//
//  RecommedNetManager.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/3/11.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHHomePage.h"


@interface RecommedNetManager : BaseNetManager
/**
 *  获取首页推荐信息
 *
 *  @param complete 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)recommedInfoWithCompletionHandler:(void(^)(JHHomePage *responseObject, NSError *error))completionHandler;
@end
