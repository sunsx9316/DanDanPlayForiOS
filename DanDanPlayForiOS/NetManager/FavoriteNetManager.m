//
//  FavoriteNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FavoriteNetManager.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>

@implementation FavoriteNetManager

+ (NSURLSessionDataTask *)favoriteLikeWithUser:(JHUser *)user
                                       animeId:(NSUInteger)animeId
                                          like:(BOOL)like
                             completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (user.identity == 0 || animeId == 0 || user.token.length == 0){
        completionHandler(jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        return nil;
    }
    
    NSDictionary *dic = @{@"UserId" : @(user.identity), @"Token" : user.token, @"AnimeId" : @(animeId)};
    
    if (like) {
        NSString *json = [dic jsonStringEncoded];
        
        return [self PUTDataWithPath:[NSString stringWithFormat:@"%@/favorite?clientId=%@", API_PATH, CLIENT_ID] data:[[json dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
            completionHandler(model.error);
        }];
    }
    
    return [self DELETEWithPath:[NSString stringWithFormat:@"%@/favorite?clientId=%@", API_PATH, CLIENT_ID] parameters:dic completionHandler:^(JHResponse *model) {
        completionHandler(model.error);
    }];
}

+ (NSURLSessionDataTask *)favoriteAnimateWithUser:(JHUser *)user
                                completionHandler:(void(^)(JHFavoriteCollection *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (user.identity == 0 || user.token.length == 0){
        completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        return nil;
    }
    
    NSDictionary *dic = @{@"userId" : @(user.identity), @"token" : user.token};
    return [self GETWithPath:[NSString stringWithFormat:@"%@/favorite", API_PATH] parameters:dic completionHandler:^(JHResponse *model) {
        completionHandler([JHFavoriteCollection yy_modelWithJSON:model.responseObject], model.error);
    }];
}

+ (NSURLSessionDataTask *)favoriteHistoryAnimateWithUser:(JHUser *)user
                                               animateId:(NSUInteger)animateId
                                       completionHandler:(void(^)(JHPlayHistory *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (animateId == 0){
        completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        return nil;
    }
    
    NSDictionary *dic = @{@"userId" : @(user.identity), @"token" : user.token.length ? user.token : @"0"};
    return [self GETWithPath:[NSString stringWithFormat:@"%@/playhistory/%ld", API_PATH, animateId] parameters:dic completionHandler:^(JHResponse *model) {
        completionHandler([JHPlayHistory yy_modelWithJSON:model.responseObject], model.error);
    }];
}

+ (NSURLSessionDataTask *)favoriteAddHistoryWithUser:(JHUser *)user
                                           episodeId:(NSUInteger)episodeId addToFavorite:(BOOL)AddToFavorite
                                   completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (user.identity == 0 || user.token.length == 0 || episodeId == 0){
        completionHandler(jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        return nil;
    }
    
    NSDictionary *dic = @{@"UserId" : @(user.identity), @"Token" : user.token, @"EpisodeId" : @(episodeId), @"AddToFavorite" : @(AddToFavorite)};
    NSString *json = [dic jsonStringEncoded];
    
    return [self PUTDataWithPath:[NSString stringWithFormat:@"%@/playhistory?clientId=%@", API_PATH, CLIENT_ID] data:[[json dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        completionHandler(model.error);
    }];
}

@end
