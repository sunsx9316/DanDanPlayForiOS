//
//  DDPRelatedNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPRelatedCollection.h"

@interface DDPRelatedNetManagerOperation : NSObject

/**
 获取指定节目编号对应的所有第三方弹幕源信息

 @param episodeId 节目编号
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)relatedDanmakuWithEpisodeId:(NSUInteger)episodeId
                                             completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPRelatedCollection))completionHandler;



@end
