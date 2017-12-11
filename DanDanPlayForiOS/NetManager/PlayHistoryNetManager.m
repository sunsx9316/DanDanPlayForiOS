//
//  PlayHistoryNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayHistoryNetManager.h"

@implementation PlayHistoryNetManager

+ (NSURLSessionDataTask *)playHistoryWithUser:(JHUser *)user
                            completionHandler:(void(^)(JHBangumiQueueIntroCollection *responseObject, NSError *error))completionHandler {
    if (user.identity == 0 || user.token.length == 0) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/playhistory/queue/intro", API_PATH] parameters:@{@"userId" : @(user.identity), @"token" : user.token} completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHBangumiQueueIntroCollection yy_modelWithJSON:model.responseObject], model.error);
        }
    }];
}

@end
