//
//  MatchNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "MatchNetManager.h"
#import "DanmakuManager.h"

@implementation MatchNetManager

+ (NSURLSessionDataTask *)matchVideoModel:(VideoModel *)model completionHandler:(void(^)(JHMatcheCollection *responseObject, NSError *error))completionHandler {
    
    NSString *hash = model.md5;
    NSUInteger length = model.length;
    NSString *fileName = model.fileName;
    
    if (!hash.length) {
        if (completionHandler) {
            completionHandler(nil, parameterNoCompletionError());
        }
        return nil;
    }
    
    if (!fileName.length) {
        fileName = @"";
    }
    
    [CacheManager shareCacheManager].currentVideoModel = model;
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/match", API_PATH] parameters:@{@"fileName":fileName, @"hash": hash, @"length": @(length)} completionHandler:^(JHResponse *response) {
        
        JHMatcheCollection *collection = [JHMatcheCollection yy_modelWithDictionary: response.responseObject];
        if (collection.collection.count == 1) {
            JHMatche *matchModel = collection.collection.firstObject;
            [[CacheManager shareCacheManager] saveEpisodeId:matchModel.identity videoModel:model];
        }
        
        if (completionHandler) {
            completionHandler(collection, response.error);
        }
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
    
    [CacheManager shareCacheManager].currentVideoModel = model;
    
    NSMutableArray *danmakus = [DanmakuManager danmakuCacheWithVideoModel:model source:DanDanPlayDanmakuTypeOfficial].mutableCopy;
    //命中缓存
    if (danmakus.count) {
        JHDanmakuCollection *collection = [[JHDanmakuCollection alloc] init];
        collection.collection = danmakus;
        
        progressAction(1.0f);
        completionAction(collection, nil);
        
        return nil;
    }
    
    progressAction(0.1f);
    
    return [self matchVideoModel:model completionHandler:^(JHMatcheCollection *responseObject, NSError *error) {
        if (responseObject.collection.count == 1) {
            JHMatche *matchModel = responseObject.collection.firstObject;
            [CommentNetManager danmakusWithEpisodeId:matchModel.identity progressHandler:progressHandler completionHandler:completionHandler];
        }
        else {
            completionAction(nil, error);
        }
    }];
}

@end
