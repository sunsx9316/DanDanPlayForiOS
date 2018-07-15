//
//  DDPFavoriteNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFavoriteNetManagerOperation.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>

@implementation DDPFavoriteNetManagerOperation

+ (NSURLSessionDataTask *)favoriteLikeWithUser:(DDPUser *)user
                                       animeId:(NSUInteger)animeId
                                          like:(BOOL)like
                             completionHandler:(void(^)(NSError *error))completionHandler {
    if (user.identity == 0 || animeId == 0 || user.token.length == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSDictionary *dic = @{@"UserId" : @(user.identity), @"Token" : user.token, @"AnimeId" : @(animeId)};
    
    if (like) {
        NSString *path = [NSString stringWithFormat:@"%@/favorite?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
        DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
        
        return [[DDPBaseNetManager shareNetManager] PUTWithPath:path
                                                 serializerType:type parameters:ddplay_encryption(dic)
                                              completionHandler:^(DDPResponse *responseObj) {
            if (completionHandler) {
                completionHandler(responseObj.error);
            }
        }];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/favorite?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    return [[DDPBaseNetManager shareNetManager] DELETEWithPath:path
                                                serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                    parameters:dic
                                             completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)favoriteAnimateWithUser:(DDPUser *)user
                                completionHandler:(void(^)(DDPFavoriteCollection *responseObject, NSError *error))completionHandler {
    if (user.identity == 0 || user.token.length == 0){
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/favorite", [DDPMethod apiPath]];
    NSDictionary *dic = @{@"userId" : @(user.identity), @"token" : user.token};
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:dic
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
    
    NSString *path = [NSString stringWithFormat:@"%@/playhistory/%lu", [DDPMethod apiPath], (unsigned long)animateId];
    NSDictionary *dic = @{@"userId" : @(user.identity), @"token" : user.token.length ? user.token : @"0"};
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:dic
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPPlayHistory yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)favoriteAddHistoryWithUser:(DDPUser *)user
                                           episodeId:(NSUInteger)episodeId addToFavorite:(BOOL)AddToFavorite
                                   completionHandler:(void(^)(NSError *error))completionHandler {
    if (user.identity == 0 || user.token.length == 0 || episodeId == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
     NSString *path = [NSString stringWithFormat:@"%@/playhistory?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = @{@"UserId" : @(user.identity), @"Token" : user.token, @"EpisodeId" : @(episodeId), @"AddToFavorite" : @(AddToFavorite)};
    
    return [[DDPBaseNetManager shareNetManager] PUTWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                 parameters:ddplay_encryption(dic)
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

@end
