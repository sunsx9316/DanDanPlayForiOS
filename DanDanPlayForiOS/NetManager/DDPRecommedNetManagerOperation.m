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
