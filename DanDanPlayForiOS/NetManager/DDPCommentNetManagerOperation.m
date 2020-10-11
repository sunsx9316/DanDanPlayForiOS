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
#import "DDPSharedNetManager.h"

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
    
    NSMutableArray *danmakus = [DDPDanmakuManager danmakuCacheWithEpisodeId:episodeId source:DDPDanmakuTypeOfficial | DDPDanmakuTypeByUser].mutableCopy;
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
    
    NSString *path = [NSString stringWithFormat:@"%@/comment/%lu", [DDPMethod apiNewPath], (unsigned long)episodeId];
    
    //是否请求第三方弹幕
    let parameters = @{@"withRelated" : [DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku ? @"true" : @"false"};
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:parameters completionHandler:^(__kindof DDPResponse *responseObj) {
        progressAction(1.0f);
        if (responseObj.error) {
            completionAction(nil, responseObj.error);
        }
        else {
            DDPDanmakuCollection *collection = [DDPDanmakuCollection yy_modelWithJSON: responseObj.responseObject];
            collection.identity = episodeId;
            collection = [DDPDanmakuManager saveDanmakuWithObj:collection episodeId:episodeId source:DDPDanmakuTypeOfficial];
            
            completionAction(collection, nil);
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
    
    NSString *path = [NSString stringWithFormat:@"%@/comment/%lu", [DDPMethod apiNewPath], (unsigned long)episodeId];
    
    NSMutableDictionary *dic = @{@"time" : @(model.time),
                                 @"mode" : @(model.mode),
                                 @"color" : @(model.color),
                                 }.mutableCopy;
    dic[@"comment"] = model.message;
    
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                  parameters:dic
                                           completionHandler:^(DDPResponse *responseObj) {
                                               if (completionHandler) {
                                                   completionHandler(responseObj.error);
                                               }
                                           }];
}


@end
