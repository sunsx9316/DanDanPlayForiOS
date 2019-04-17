//
//  DDPRecommedNetManagerOperation.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/3/11.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPRecommedNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPRecommedNetManagerOperation
+ (NSURLSessionDataTask *)recommedInfoWithCompletionHandler:(void (^)(DDPHomePage *, NSError *))completionHandler {
    DDPUser *user = [DDPCacheManager shareCacheManager].currentUser;
    
    NSString *path;
    if (user.identity == 0) {
        path = [NSString stringWithFormat:@"%@/homepage", [DDPMethod apiPath]];
    }
    else {
        path = [NSString stringWithFormat:@"%@/homepage?userId=%lu&token=%@", [DDPMethod apiPath], (unsigned long)user.identity, user.legacyTokenNumber];
    }
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
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


+ (NSURLSessionTask *)homePageWithCompletionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPNewHomePage))completionHandler {
    NSString *path = [NSString stringWithFormat:@"%@/homepage", [DDPMethod apiNewPath]];
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:nil completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else {
            DDPNewHomePage *homePageModel = [DDPNewHomePage yy_modelWithJSON:responseObj.responseObject];
            if (completionHandler) {
                completionHandler(homePageModel, responseObj.error);
            }
        }
    }];
}

@end
