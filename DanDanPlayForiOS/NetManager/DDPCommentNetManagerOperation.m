//
//  DDPCommentNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPCommentNetManagerOperation.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "DDPDanmakuManager.h"

@implementation DDPCommentNetManagerOperation

+ (NSURLSessionDataTask *)danmakusWithEpisodeId:(NSUInteger)episodeId progressHandler:(DDPProgressAction)progressHandler completionHandler:(void (^)(DDPDanmakuCollection *, NSError *))completionHandler {
    
    void(^progressAction)(float progress) = ^(float progress) {
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHandler(progress);
            });
        }
    };
    
    void(^completionAction)(DDPDanmakuCollection *responseObject, NSError *error) = ^(DDPDanmakuCollection *responseObject, NSError *error) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(responseObject, error);
            });
        }
    };
    
    if (episodeId == 0) {
        completionAction(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSMutableArray *danmakus = [DDPDanmakuManager danmakuCacheWithEpisodeId:episodeId source:DDPDanmakuTypeOfficial].mutableCopy;
    //命中缓存
    if (danmakus.count) {
        DDPDanmakuCollection *collection = [[DDPDanmakuCollection alloc] init];
        collection.collection = danmakus;
        //修复手动搜索不能发弹幕的问题
        collection.identity = episodeId;
        
        progressAction(1.0f);
        completionAction(collection, nil);
        
        return nil;
    }
    
    //下载弹幕
    progressAction(0.3f);
    NSString *path = [NSString stringWithFormat:@"%@/comment/%lu", [DDPMethod apiPath], (unsigned long)episodeId];
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *model) {
        
        if (model.error) {
            completionAction(nil, model.error);
            return;
        }
        
        __block DDPDanmakuCollection *collection = [DDPDanmakuCollection yy_modelWithJSON:model.responseObject];
        collection.identity = episodeId;
        
        //开启自动请求第三方弹幕的功能
        if ([DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku) {
            [DDPRelatedNetManagerOperation relatedDanmakuWithEpisodeId:episodeId completionHandler:^(DDPRelatedCollection *responseObject, NSError *error) {
                //请求出错 返回之前请求成功的快速匹配弹幕
                if (error) {
                    collection = [DDPDanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DDPDanmakuTypeOfficial];
                    completionAction(collection, error);
                    return;
                }
                
                //下载第三方弹幕
                progressAction(0.6f);
                
                [self danmakuWithRelatedCollection:responseObject completionHandler:^(DDPDanmakuCollection *responseObject1, NSError *error) {
                    if (collection.collection == nil) {
                        collection.collection = [NSMutableArray array];
                    }
                    
                    //合并弹幕 并缓存
                    if (responseObject1) {
                        [collection.collection addObjectsFromArray:responseObject1.collection];
                    }
                    
                    collection = [DDPDanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DDPDanmakuTypeOfficial];
                    
                    progressAction(1.0f);
                    completionAction(collection, error);
                }];
            }];
        }
        else {
            collection = [DDPDanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DDPDanmakuTypeOfficial];
            
            progressAction(1.0f);
            completionAction(collection, model.error);
        }
    }];
}

+ (NSURLSessionDataTask *)launchDanmakuWithModel:(DDPDanmaku *)model
                                       episodeId:(NSUInteger)episodeId
                               completionHandler:(void(^)(NSError *))completionHandler{
    if (!model || episodeId == 0) {
        if (completionHandler == nil) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/comment/%lu?clientId=%@", [DDPMethod apiPath], (unsigned long)episodeId, CLIENT_ID];
    
    return [[DDPBaseNetManager shareNetManager] PUTWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                 parameters:ddplay_encryption([model yy_modelToJSONObject])
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (void)danmakuWithRelatedCollection:(DDPRelatedCollection *)relatedCollection
                   completionHandler:(void(^)(DDPDanmakuCollection *responseObject, NSError *error))completionHandler {
    
    if (completionHandler == nil) return;
    
    if (relatedCollection.collection.count == 0) {
        completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return;
    }
    
    NSMutableArray *paths = [NSMutableArray array];
    [relatedCollection.collection enumerateObjectsUsingBlock:^(DDPRelated * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [paths addObject:[NSString stringWithFormat:@"%@/extcomment?url=%@", [DDPMethod apiPath], obj.url]];
    }];
    
    [[DDPBaseNetManager shareNetManager] batchGETWithPaths:paths serializerType:DDPBaseNetManagerSerializerTypeJSON editResponseBlock:nil progressBlock:nil completionHandler:^(NSArray<DDPBatchResponse *> *responseObjects, NSError *error) {
        DDPDanmakuCollection *responseObject = [[DDPDanmakuCollection alloc] init];
        responseObject.collection = [NSMutableArray array];
        
        [responseObjects enumerateObjectsUsingBlock:^(DDPBatchResponse * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [responseObject.collection addObjectsFromArray:[DDPDanmakuCollection yy_modelWithDictionary:obj.responseObject].collection];
        }];
        
        completionHandler(responseObject, error);
    }];
}

@end
