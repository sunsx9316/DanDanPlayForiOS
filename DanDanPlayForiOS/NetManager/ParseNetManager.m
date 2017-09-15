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
    if (completionHandler == nil) return nil;
    
    if (url.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/dmhy/parse", API_DMHY_DOMAIN] parameters:@{@"url" : url} completionHandler:^(JHResponse *model) {
        completionHandler([JHDMHYParse yy_modelWithJSON:model.responseObject], model.error);
    }];
}

@end
