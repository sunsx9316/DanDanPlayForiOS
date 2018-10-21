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

typedef NSString* DDPFavoriteStatus;

FOUNDATION_EXPORT DDPFavoriteStatus DDPFavoriteStatusFavorited;
FOUNDATION_EXPORT DDPFavoriteStatus DDPFavoriteStatusFinished;
FOUNDATION_EXPORT DDPFavoriteStatus DDPFavoriteStatusAbandoned;

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
 @param episodeIds 分集id集合
 @param addToFavorite 是否自动关注
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)addHistoryWithEpisodeIds:(NSArray <NSNumber *>*)episodeIds
                                            addToFavorite:(BOOL)addToFavorite
                                       completionHandler:(DDPErrorCompletionAction)completionHandler;


/**
 更改收藏新番状态

 @param animeId id
 @param like s是否收藏
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)changeFavoriteStatusWithAnimeId:(NSUInteger)animeId
                                          like:(BOOL)like
                                        completionHandler:(DDPErrorCompletionAction)completionHandler;

@end
