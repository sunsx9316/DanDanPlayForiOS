//
//  DDPFavoriteNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPFavoriteCollection.h"
#import "DDPPlayHistory.h"

@interface DDPFavoriteNetManagerOperation : NSObject

/**
 收藏一个新番

 @param user 用户
 @param animeId 新番id
 @param like 是否喜欢
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteLikeWithUser:(DDPUser *)user
                                         animeId:(NSUInteger)animeId
                                            like:(BOOL)like
                        completionHandler:(DDPErrorCompletionAction)completionHandler;

/**
 获取用户收藏列表

 @param user 用户
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteAnimateWithUser:(DDPUser *)user
                               completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPFavoriteCollection))completionHandler;

/**
 获取动画观看记录

 @param user 用户
 @param animateId 动画id
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteHistoryAnimateWithUser:(DDPUser *)user
                                               animateId:(NSUInteger)animateId
                                completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPPlayHistory))completionHandler;

/**
 添加观看记录

 @param user 用户
 @param episodeId 分集id
 @param AddToFavorite 是否自动关注
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteAddHistoryWithUser:(DDPUser *)user
                                           episodeId:(NSUInteger)episodeId addToFavorite:(BOOL)AddToFavorite
                                       completionHandler:(DDPErrorCompletionAction)completionHandler;

@end
