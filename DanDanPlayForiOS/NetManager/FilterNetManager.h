//
//  FilterNetManager.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/2/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHFilterCollection.h"

@interface FilterNetManager : BaseNetManager
/**
 *  获取云过滤列表
 *
 *  @param completionHandler 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)cloudFilterListWithCompletionHandler:(void(^)(JHFilterCollection *responseObject, NSError *error))completionHandler;
@end
