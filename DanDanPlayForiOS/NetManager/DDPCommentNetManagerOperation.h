//
//  DDPCommentNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPDanmakuCollection.h"


CG_INLINE NSString *ddp_danmakusProgressToString(float progress) {
    if (progress == 0.1f) {
        return @"快速匹配...";
    }
    
    if (progress == 0.3f) {
        return @"下载弹幕...";
    }
    
    if (progress == 0.6f) {
        return @"下载第三方弹幕...";
    }
    
    return @"加载中...";
};

@class DDPRelatedCollection;
@interface DDPCommentNetManagerOperation : NSObject

/**
 获取指定弹幕库（节目编号）的所有弹幕

 @param episodeId 节目编号
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)danmakusWithEpisodeId:(NSUInteger)episodeId
                                progressHandler:(DDPProgressAction)progressHandler
                              completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPDanmakuCollection))completionHandler;

/**
 *  发射弹幕方法
 *
 *  @param model     弹幕模型
 *  @param episodeId 节目id
 *  @param completionHandler  回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)launchDanmakuWithModel:(DDPDanmaku *)model
                                       episodeId:(NSUInteger)episodeId
                               completionHandler:(DDPErrorCompletionAction)completionHandler;


/**
 批量下载弹幕

 @param relatedCollection 匹配到的弹幕
 @param completionHandler 回调
 */
+ (void)danmakuWithRelatedCollection:(DDPRelatedCollection *)relatedCollection
                                    completionHandler:(void(^)(DDPDanmakuCollection *responseObject, NSError *error))completionHandler;

@end
