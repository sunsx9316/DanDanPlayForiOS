//
//  DDPPlayHistoryNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayHistoryNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPPlayHistoryNetManagerOperation

+ (NSURLSessionDataTask *)playHistoryWithUser:(DDPUser *)user
                            completionHandler:(void(^)(DDPBangumiQueueIntroCollection *responseObject, NSError *error))completionHandler {
    if (user.isLogin == NO) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/bangumi/queue/intro", [DDPMethod apiNewPath]];
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPBangumiQueueIntroCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)playHistoryDetailWithUser:(DDPUser *)user
                                  completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPBangumiQueueIntroCollection))completionHandler {
    if (user.isLogin == NO) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/bangumi/queue/details", [DDPMethod apiNewPath]];
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler([DDPBangumiQueueIntroCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
                                              }
                                          }];
}

@end
