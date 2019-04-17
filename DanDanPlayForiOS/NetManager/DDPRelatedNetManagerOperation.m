//
//  DDPRelatedNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPRelatedNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPRelatedNetManagerOperation

+ (NSURLSessionDataTask *)relatedDanmakuWithEpisodeId:(NSUInteger)episodeId completionHandler:(void (^)(DDPRelatedCollection *, NSError *))completionHandler {
    if (episodeId == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/related/%lu", [DDPMethod apiPath], (unsigned long)episodeId];
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPRelatedCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

@end
