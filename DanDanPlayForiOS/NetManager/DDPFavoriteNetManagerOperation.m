//
//  DDPFavoriteNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFavoriteNetManagerOperation.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "DDPSharedNetManager.h"

DDPFavoriteStatus DDPFavoriteStatusFavorited = @"favorited";
DDPFavoriteStatus DDPFavoriteStatusFinished = @"finished";
DDPFavoriteStatus DDPFavoriteStatusAbandoned = @"abandoned";

@implementation DDPFavoriteNetManagerOperation

+ (NSURLSessionDataTask *)favoriteLikeWithUser:(DDPUser *)user
                                       animeId:(NSUInteger)animeId
                                          like:(BOOL)like
                             completionHandler:(void(^)(NSError *error))completionHandler {
    if (user.isLogin == NO || animeId == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    
    if (like) {
        NSDictionary *dic = @{@"favoriteStatus" : @"favorited",
                              @"animeId" : @(animeId),
                              @"rating" : @0};
        
        NSString *path = [NSString stringWithFormat:@"%@/favorite", [DDPMethod apiNewPath]];
        DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerTypeJSON;
        
        return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path
                                                 serializerType:type parameters:dic
                                              completionHandler:^(DDPResponse *responseObj) {
            if (completionHandler) {
                completionHandler(responseObj.error);
            }
        }];
    } else {
        NSString *path = [NSString stringWithFormat:@"%@/favorite/%lu", [DDPMethod apiNewPath], (unsigned long)animeId];
        return [[DDPSharedNetManager sharedNetManager] DELETEWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:nil completionHandler:^(__kindof DDPResponse *responseObj) {
            if (completionHandler) {
                completionHandler(responseObj.error);
            }
        }];
    }
}

+ (NSURLSessionDataTask *)favoriteAnimateWithUser:(DDPUser *)user
                                completionHandler:(void(^)(DDPFavoriteCollection *responseObject, NSError *error))completionHandler {
    if (user.identity == 0 || user.legacyTokenNumber.length == 0){
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/favorite", [DDPMethod apiNewPath]];
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPFavoriteCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)favoriteHistoryAnimateWithUser:(DDPUser *)user
                                               animateId:(NSUInteger)animateId
                                       completionHandler:(void(^)(DDPPlayHistory *responseObject, NSError *error))completionHandler {
    if (animateId == 0){
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/bangumi/%lu", [DDPMethod apiNewPath], (unsigned long)animateId];
//    NSString *token = user.legacyTokenNumber.length ? user.legacyTokenNumber : @"0";
//    NSDictionary *dic = @{@"userId" : @(user.identity), @"token" : token};
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            NSDictionary *responseObject = responseObj.responseObject;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                responseObject = responseObject[@"bangumi"];
            }
            completionHandler([DDPPlayHistory yy_modelWithJSON:responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)addHistoryWithEpisodeIds:(NSArray <NSNumber *>*)episodeIds
                                     addToFavorite:(BOOL)addToFavorite
                                 completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (episodeIds.count == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/playhistory", [DDPMethod apiNewPath]];
    NSDictionary *dic = @{@"episodeIdList" : episodeIds, @"addToFavorite" : @(addToFavorite)};
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:dic completionHandler:^(__kindof DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)changeFavoriteStatusWithAnimeId:(NSUInteger)animeId
                                                     like:(BOOL)like
                                        completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (animeId == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    
    if (like) {
        NSDictionary *dic = @{@"animeId" : @(animeId), @"favoriteStatus" : DDPFavoriteStatusFavorited};
        NSString *path = [NSString stringWithFormat:@"%@/favorite", [DDPMethod apiNewPath]];
        return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path
                                                  serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                      parameters:dic
                                               completionHandler:^(DDPResponse *responseObj) {
                                                   if (completionHandler) {
                                                       completionHandler(responseObj.error);
                                                   }
                                               }];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/favorite/%lu", [DDPMethod apiNewPath], (unsigned long)animeId];
    NSDictionary *dic = @{@"animeId" : @(animeId)};
    return [[DDPSharedNetManager sharedNetManager] DELETEWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                  parameters:dic
                                           completionHandler:^(DDPResponse *responseObj) {
                                               if (completionHandler) {
                                                   completionHandler(responseObj.error);
                                               }
                                           }];
    
}

@end
