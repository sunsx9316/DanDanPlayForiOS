//
//  DDPPlayHistoryNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayHistoryNetManagerOperation.h"

@implementation DDPPlayHistoryNetManagerOperation

+ (NSURLSessionDataTask *)playHistoryWithUser:(DDPUser *)user
                            completionHandler:(void(^)(DDPBangumiQueueIntroCollection *responseObject, NSError *error))completionHandler {
    if (user.identity == 0 || user.token.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/playhistory/queue/intro", API_PATH];
    NSDictionary *parameters = @{@"userId" : @(user.identity), @"token" : user.token};
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:parameters
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPBangumiQueueIntroCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)playHistoryDetailWithUser:(DDPUser *)user
                                  completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPBangumiQueueIntroCollection))completionHandler {
    if (user.identity == 0 || user.token.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/playhistory/queue/details", API_PATH];
    NSDictionary *parameters = @{@"userId" : @(user.identity), @"token" : user.token};
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:parameters
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler([DDPBangumiQueueIntroCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
                                              }
                                          }];
}

@end
