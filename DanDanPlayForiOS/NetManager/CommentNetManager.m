//
//  CommentNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "CommentNetManager.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "DanmakuManager.h"

@implementation CommentNetManager

+ (NSURLSessionDataTask *)danmakusWithEpisodeId:(NSUInteger)episodeId progressHandler:(progressAction)progressHandler completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSError *error))completionHandler {
    
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
    
    if (episodeId == 0) {
        completionAction(nil, parameterNoCompletionError());
        return nil;
    }
    
    NSMutableArray *danmakus = [DanmakuManager danmakuCacheWithEpisodeId:episodeId source:DanDanPlayDanmakuTypeOfficial].mutableCopy;
    //命中缓存
    if (danmakus.count) {
        JHDanmakuCollection *collection = [[JHDanmakuCollection alloc] init];
        collection.collection = danmakus;
        //修复手动搜索不能发弹幕的问题
        collection.identity = episodeId;
        
        progressAction(1.0f);
        completionAction(collection, nil);
        
        return nil;
    }
    
    //下载弹幕
    progressAction(0.3f);
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/comment/%ld", API_PATH, episodeId] parameters:nil completionHandler:^(JHResponse *model) {
        
        if (model.error) {
            completionAction(nil, model.error);
            return;
        }
        
        __block JHDanmakuCollection *collection = [JHDanmakuCollection yy_modelWithJSON:model.responseObject];
        collection.identity = episodeId;
        
        //开启自动请求第三方弹幕的功能
        if ([CacheManager shareCacheManager].autoRequestThirdPartyDanmaku) {
            [RelatedNetManager relatedDanmakuWithEpisodeId:episodeId completionHandler:^(JHRelatedCollection *responseObject, NSError *error) {
                //请求出错 返回之前请求成功的快速匹配弹幕
                if (error) {
                    collection = [DanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DanDanPlayDanmakuTypeOfficial];
                    completionAction(collection, error);
                    return;
                }
                
                //下载第三方弹幕
                progressAction(0.6f);
                
                [self danmakuWithRelatedCollection:responseObject completionHandler:^(JHDanmakuCollection *responseObject1, NSArray<NSError *> *errors1) {
                    
                    if (collection.collection == nil) {
                        collection.collection = [NSMutableArray array];
                    }
                    
                    //合并弹幕 并缓存
                    [collection.collection addObjectsFromArray:responseObject1.collection];
                    collection = [DanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DanDanPlayDanmakuTypeOfficial];
                    
                    progressAction(1.0f);
                    completionAction(collection, errors1.firstObject);
                }];
            }];
        }
        else {
            collection = [DanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DanDanPlayDanmakuTypeOfficial];
            
            progressAction(1.0f);
            completionAction(collection, model.error);
        }
    }];
}

+ (NSURLSessionDataTask *)launchDanmakuWithModel:(JHDanmaku *)model
                                       episodeId:(NSUInteger)episodeId
                               completionHandler:(void(^)(NSError *))completionHandler{
    if (!model || episodeId == 0) {
        if (completionHandler == nil) {
            completionHandler(parameterNoCompletionError());
        }
        return nil;
    }
    
    return [self PUTWithPath:[NSString stringWithFormat:@"%@/comment/%ld?clientId=ddplayios", API_PATH, episodeId] HTTPBody:[[model yy_modelToJSONData] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler(model.error);
        }
    }];
}

+ (void)danmakuWithRelatedCollection:(JHRelatedCollection *)relatedCollection
                   completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSArray <NSError *>*errors))completionHandler {
    if (completionHandler == nil) return;
    
    if (relatedCollection.collection.count == 0) {
        completionHandler(nil, @[parameterNoCompletionError()]);
        return;
    }
    
    NSMutableArray *paths = [NSMutableArray array];
    [relatedCollection.collection enumerateObjectsUsingBlock:^(JHRelated * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [paths addObject:[NSString stringWithFormat:@"%@/extcomment?url=%@", API_PATH, obj.url]];
    }];
    
    [self batchGETWithPaths:paths progressBlock:nil completionHandler:^(NSArray *responseObjects, NSArray<NSURLSessionTask *> *tasks, NSArray<NSError *> *errors) {
        
        JHDanmakuCollection *responseObject = [[JHDanmakuCollection alloc] init];
        responseObject.collection = [NSMutableArray array];
        [responseObjects enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [responseObject.collection addObjectsFromArray:[JHDanmakuCollection yy_modelWithDictionary:obj].collection];
        }];
        
        completionHandler(responseObject, errors);
    }];
}

@end
