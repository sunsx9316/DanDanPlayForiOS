//
//  FavoriteNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FavoriteNetManager.h"

@implementation FavoriteNetManager

+ (NSURLSessionDataTask *)favoriteLikeWithUserId:(NSUInteger)userId
                                           token:(NSString *)token
                                         animeId:(NSUInteger)animeId
                               completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId == 0 || animeId == 0 || token.length == 0){
        completionHandler(parameterNoCompletionError());
        return nil;
    }
    
    NSDictionary *dic = @{@"UserId" : @(userId), @"Token" : token, @"AnimeId" : @(animeId)};
    
    return [self PUTWithPath:[NSString stringWithFormat:@"%@/favorite?clientId=%@", API_PATH, CLIENT_ID] HTTPBody:[[dic jsonStringEncoded] dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(JHResponse *model) {
        completionHandler(model.error);
    }];
}

+ (NSURLSessionDataTask *)favoriteUnlikeWithUserId:(NSUInteger)userId
                                             token:(NSString *)token
                                           animeId:(NSUInteger)animeId
                                 completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId == 0 || animeId == 0 || token.length == 0){
        completionHandler(parameterNoCompletionError());
        return nil;
    }
    
    NSDictionary *dic = @{@"UserId" : @(userId), @"Token" : token, @"AnimeId" : @(animeId)};
    return [self DELETEWithPath:[NSString stringWithFormat:@"%@/favorite?clientId=%@", API_PATH, CLIENT_ID] parameters:dic completionHandler:^(JHResponse *model) {
        completionHandler(model.error);
    }];
}

@end
