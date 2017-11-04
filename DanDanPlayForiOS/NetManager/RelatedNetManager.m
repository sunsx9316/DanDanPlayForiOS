//
//  RelatedNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "RelatedNetManager.h"

@implementation RelatedNetManager

+ (NSURLSessionDataTask *)relatedDanmakuWithEpisodeId:(NSUInteger)episodeId
                                    completionHandler:(void(^)(JHRelatedCollection *responseObject, NSError *error))completionHandler {
    if (episodeId == 0) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/related/%lu", API_PATH, (unsigned long)episodeId] parameters:nil completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHRelatedCollection yy_modelWithJSON:model.responseObject], model.error);
        }
    }];
}

@end
