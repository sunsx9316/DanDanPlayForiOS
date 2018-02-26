//
//  DDPRecommedNetManagerOperation.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/3/11.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPRecommedNetManagerOperation.h"

@implementation DDPRecommedNetManagerOperation
+ (NSURLSessionDataTask *)recommedInfoWithCompletionHandler:(void (^)(DDPHomePage *, NSError *))completionHandler {
    DDPUser *user = [DDPCacheManager shareCacheManager].user;
    
    NSString *path;
    if (user.identity == 0) {
        path = [NSString stringWithFormat:@"%@/homepage", API_PATH];
    }
    else {
        path = [NSString stringWithFormat:@"%@/homepage?userId=%lu&token=%@", API_PATH, (unsigned long)user.identity, user.token];
    }
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeXML
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else {
            DDPHomePage *homePageModel = [DDPHomePage yy_modelWithJSON:responseObj.responseObject];
            if (completionHandler) {
                completionHandler(homePageModel, responseObj.error);
            }
        }
    }];
}
@end
