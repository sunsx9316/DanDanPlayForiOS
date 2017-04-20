//
//  CommentNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHDanmakuCollection.h"

@class JHRelatedCollection;
@interface CommentNetManager : BaseNetManager

/**
 获取指定弹幕库（节目编号）的所有弹幕

 @param programId 节目编号
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)danmakusWithProgramId:(NSUInteger)programId completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSError *error))completionHandler;

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
                               completionHandler:(void(^)(NSError *))completionHandler;


/**
 批量下载弹幕

 @param relatedCollection 匹配到的弹幕
 @param completionHandler 回调
 */
+ (void)danmakuWithRelatedCollection:(JHRelatedCollection *)relatedCollection
                                    completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSArray <NSError *>*errors))completionHandler;

@end
