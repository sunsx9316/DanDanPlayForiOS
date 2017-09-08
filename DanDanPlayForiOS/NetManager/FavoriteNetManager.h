//
//  FavoriteNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHFavoriteCollection.h"
#import "JHPlayHistory.h"

@interface FavoriteNetManager : BaseNetManager

/**
 收藏一个新番

 @param user 用户
 @param animeId 新番id
 @param like 是否喜欢
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteLikeWithUser:(JHUser *)user
                                         animeId:(NSUInteger)animeId
                                            like:(BOOL)like
                        completionHandler:(void(^)(NSError *error))completionHandler;

/**
 获取用户收藏列表

 @param user 用户
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteAnimateWithUser:(JHUser *)user
                               completionHandler:(void(^)(JHFavoriteCollection *responseObject, NSError *error))completionHandler;

/**
 获取动画观看记录

 @param user 用户
 @param animateId 动画id
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteHistoryAnimateWithUser:(JHUser *)user
                                               animateId:(NSUInteger)animateId
                                completionHandler:(void(^)(JHPlayHistory *responseObject, NSError *error))completionHandler;

/**
 添加观看记录

 @param user 用户
 @param episodeId 分集id
 @param AddToFavorite 是否自动关注
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteAddHistoryWithUser:(JHUser *)user
                                           episodeId:(NSUInteger)episodeId addToFavorite:(BOOL)AddToFavorite
                                       completionHandler:(void(^)(NSError *error))completionHandler;

@end
