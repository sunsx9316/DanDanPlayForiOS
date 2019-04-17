//
//  DDPMatchNetManagerOperation.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPMatchNetManagerOperation.h"
#import "DDPDanmakuManager.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "DDPCacheManager+multiply.h"
#import "DDPVideoModel+Tools.h"
#import "DDPSharedNetManager.h"

@implementation DDPMatchNetManagerOperation

+ (NSURLSessionDataTask *)matchVideoModel:(DDPVideoModel *)model completionHandler:(void (^)(DDPMatchCollection *, NSError *))completionHandler {
    
    NSString *hash = model.fileHash;
    NSUInteger length = model.length;
    NSString *fileName = model.name;
    
    if (!hash.length) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    if (!fileName.length) {
        fileName = @"";
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/match", [DDPMethod apiNewPath]];
    NSDictionary *parameters = @{@"fileName":fileName, @"fileHash": hash, @"fileSize": @(length)};
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:parameters completionHandler:^(DDPResponse *responseObj) {
        
        DDPMatchCollection *collection = [DDPMatchCollection yy_modelWithDictionary: responseObj.responseObject];
        //精准匹配
        if (collection.collection.count == 1) {
            DDPMatch *matchModel = collection.collection.firstObject;
            model.matchName = matchModel.name;
            [[DDPCacheManager shareCacheManager] saveEpisodeId:matchModel.identity episodeName:matchModel.name videoModel:model];
        }
        
        if (completionHandler) {
            completionHandler(collection, responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)matchEditMatchVideoModel:(DDPVideoModel *)model
                                              user:(DDPUser *)user
                                 completionHandler:(void(^)(NSError *error))completionHandler {
    if (user.identity == 0 || user.legacyTokenNumber.length == 0 || model.name.length == 0 || model.fileHash.length == 0 || model.identity == 0) {
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/match?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = @{@"UserId" : @(user.identity),
                          @"Token" : user.legacyTokenNumber,
                          @"FileName" : model.name,
                          @"Hash" : model.fileHash,
                          @"EpisodeId" : @(model.identity)};
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                  parameters:ddplay_encryption(dic)
                                           completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)fastMatchVideoModel:(DDPVideoModel *)model progressHandler:(DDPProgressAction)progressHandler completionHandler:(void (^)(DDPDanmakuCollection *, NSError *))completionHandler {
    
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
    
    NSMutableArray *danmakus = [DDPDanmakuManager danmakuCacheWithVideoModel:model source:DDPDanmakuTypeOfficial | DDPDanmakuTypeByUser].mutableCopy;
    //命中缓存
    if (danmakus.count) {
        DDPDanmakuCollection *collection = [[DDPDanmakuCollection alloc] init];
        collection.collection = danmakus;
        model.matchName = model.relevanceName;
        model.identity = model.relevanceEpisodeId;
        
        progressAction(1.0f);
        completionAction(collection, nil);
        
        return nil;
    }
    
    progressAction(0.1f);
    
    return [self matchVideoModel:model completionHandler:^(DDPMatchCollection *responseObject, NSError *error) {
        //精确匹配
        if (responseObject.collection.count == 1) {
            DDPMatch *matchModel = responseObject.collection.firstObject;
            //获取弹幕
            [DDPCommentNetManagerOperation danmakusWithEpisodeId:matchModel.identity progressHandler:progressHandler completionHandler:completionHandler];
        }
        else {
            completionAction(nil, error);
        }
    }];
}

@end
