//
//  MatchNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "MatchNetManager.h"
#import "DanmakuManager.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>

@implementation MatchNetManager

+ (NSURLSessionDataTask *)matchVideoModel:(VideoModel *)model completionHandler:(void(^)(JHMatcheCollection *responseObject, NSError *error))completionHandler {
    
    NSString *hash = model.md5;
    NSUInteger length = model.length;
    NSString *fileName = model.name;
    
    if (!hash.length) {
        if (completionHandler) {
            completionHandler(nil, jh_parameterNoCompletionError());
        }
        return nil;
    }
    
    if (!fileName.length) {
        fileName = @"";
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/match", API_PATH] parameters:@{@"fileName":fileName, @"hash": hash, @"length": @(length)} completionHandler:^(JHResponse *response) {
        
        JHMatcheCollection *collection = [JHMatcheCollection yy_modelWithDictionary: response.responseObject];
        //精准匹配
        if (collection.collection.count == 1) {
            JHMatche *matchModel = collection.collection.firstObject;
            model.matchName = matchModel.name;
            [[CacheManager shareCacheManager] saveEpisodeId:matchModel.identity episodeName:matchModel.name videoModel:model];
        }
        
        if (completionHandler) {
            completionHandler(collection, response.error);
        }
    }];
}

+ (NSURLSessionDataTask *)matchEditMatchVideoModel:(VideoModel *)model
                                              user:(JHUser *)user
                                 completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (user.identity == 0 || user.token.length == 0 || model.name.length == 0 || model.md5.length == 0 || model.identity == 0) {
        completionHandler(jh_parameterNoCompletionError());
        return nil;
    }
    
    NSDictionary *dic = @{@"UserId" : @(user.identity), @"Token" : user.token, @"FileName" : model.name, @"Hash" : model.md5, @"EpisodeId" : @(model.identity)};
    
    return [self POSTDataWithPath:[NSString stringWithFormat:@"%@/match?clientId=%@", API_PATH, CLIENT_ID] data:[[[dic jsonStringEncoded] dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        completionHandler(model.error);
    }];
}

+ (NSURLSessionDataTask *)fastMatchVideoModel:(VideoModel *)model progressHandler:(progressAction)progressHandler completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSError *error))completionHandler {
    
    void(^progressAction)(float progress) = ^(float progress) {
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHandler(progress);
            });
        }
    };
    
    void(^completionAction)(JHDanmakuCollection *responseObject, NSError *error) = ^(JHDanmakuCollection *responseObject, NSError *error) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(responseObject, error);
            });
        }
    };
    
    NSMutableArray *danmakus = [DanmakuManager danmakuCacheWithVideoModel:model source:DanDanPlayDanmakuTypeOfficial].mutableCopy;
    //命中缓存
    if (danmakus.count) {
        JHDanmakuCollection *collection = [[JHDanmakuCollection alloc] init];
        collection.collection = danmakus;
        
        NSDictionary *dic = [[CacheManager shareCacheManager] episodeInfoWithVideoModel:model];
        model.matchName = dic[videoNameKey];
        model.identity = [dic[videoEpisodeIdKey] integerValue];
        
        progressAction(1.0f);
        completionAction(collection, nil);
        
        return nil;
    }
    
    progressAction(0.1f);
    
    return [self matchVideoModel:model completionHandler:^(JHMatcheCollection *responseObject, NSError *error) {
        //精确匹配
        if (responseObject.collection.count == 1) {
            JHMatche *matchModel = responseObject.collection.firstObject;
            //获取弹幕
            [CommentNetManager danmakusWithEpisodeId:matchModel.identity progressHandler:progressHandler completionHandler:completionHandler];
        }
        else {
            completionAction(nil, error);
        }
    }];
}

@end
