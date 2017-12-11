//
//  ParseNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "ParseNetManager.h"

@implementation ParseNetManager

+ (NSURLSessionDataTask *)parseDMHYWithURL:(NSString *)url
                         completionHandler:(void(^)(JHDMHYParse *responseObject, NSError *error))completionHandler {
    if (url.length == 0) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/dmhy/parse", API_DMHY_DOMAIN] parameters:@{@"url" : url} completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHDMHYParse yy_modelWithJSON:model.responseObject], model.error);
        }
    }];
}

@end
