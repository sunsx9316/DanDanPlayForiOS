//
//  CommentNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHDanmakuCollection.h"


CG_INLINE NSString *jh_danmakusProgressToString(float progress) {
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

@class JHRelatedCollection;
@interface CommentNetManager : BaseNetManager

/**
 获取指定弹幕库（节目编号）的所有弹幕

 @param episodeId 节目编号
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)danmakusWithEpisodeId:(NSUInteger)episodeId
                                progressHandler:(progressAction)progressHandler
                              completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSError *error))completionHandler;

/**
 *  发射弹幕方法
 *
 *  @param model     弹幕模型
 *  @param episodeId 节目id
 *  @param completionHandler  回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)launchDanmakuWithModel:(JHDanmaku *)model
                                       episodeId:(NSUInteger)episodeId
                               completionHandler:(void(^)(NSError *error))completionHandler;


/**
 批量下载弹幕

 @param relatedCollection 匹配到的弹幕
 @param completionHandler 回调
 */
+ (void)danmakuWithRelatedCollection:(JHRelatedCollection *)relatedCollection
                                    completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSArray <NSError *>*errors))completionHandler;

@end
