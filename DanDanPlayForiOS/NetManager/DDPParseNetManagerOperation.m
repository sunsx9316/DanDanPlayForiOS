//
//  DDPParseNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPParseNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPParseNetManagerOperation

+ (NSURLSessionDataTask *)parseDMHYWithURL:(NSString *)url
                         completionHandler:(void(^)(DDPDMHYParse *responseObject, NSError *error))completionHandler {
    if (url.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/dmhy/parse", API_DMHY_DOMAIN];
    NSDictionary *parameters = @{@"url" : url};
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:parameters
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPDMHYParse yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

@end
