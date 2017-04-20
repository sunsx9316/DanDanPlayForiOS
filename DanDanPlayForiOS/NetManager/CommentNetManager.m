//
//  CommentNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "CommentNetManager.h"
#import "NSData+Tools.h"

@implementation CommentNetManager

+ (NSURLSessionDataTask *)danmakusWithProgramId:(NSUInteger)programId completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSError *error))completionHandler {
    
    if (programId == 0) {
        if (completionHandler) {
            completionHandler(nil, parameterNoCompletionError());
        }
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/comment/%ld", API_PATH, programId] parameters:nil completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHDanmakuCollection yy_modelWithJSON:model.responseObject], model.error);
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
