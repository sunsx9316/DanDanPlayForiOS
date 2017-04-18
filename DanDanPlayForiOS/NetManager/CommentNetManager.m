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

@end
