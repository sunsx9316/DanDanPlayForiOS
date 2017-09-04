//
//  FavoriteNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"

@interface FavoriteNetManager : BaseNetManager

/**
 收藏一个新番

 @param userId 用户id
 @param token 用户token
 @param animeId 新番id
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteLikeWithUserId:(NSUInteger)userId
                                           token:(NSString *)token
                                         animeId:(NSUInteger)animeId
                        completionHandler:(void(^)(NSError *error))completionHandler;

/**
 取消搜藏新番

 @param userId 用户id
 @param token 用户token
 @param animeId 新番id
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)favoriteUnlikeWithUserId:(NSUInteger)userId
                                             token:(NSString *)token
                                     animeId:(NSUInteger)animeId
                           completionHandler:(void(^)(NSError *error))completionHandler;

@end
