//
//  DDPBangumiNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPBangumiNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPBangumiNetManagerOperation

+ (NSURLSessionDataTask *)seasonListWithYear:(NSInteger)year
                                       month:(NSInteger)month
                           completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPNewBangumiIntroCollection))completionHandler {
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:[NSString stringWithFormat:@"%@/bangumi/season/anime/%ld/%ld", [DDPMethod apiNewPath], (long)year, (long)month] serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:nil completionHandler:^(__kindof DDPResponse *responseObj) {
        if (completionHandler) {
            if (responseObj.error) {
                completionHandler(nil, responseObj.error);
            }
            else {
                let model = [DDPNewBangumiIntroCollection yy_modelWithJSON:responseObj.responseObject];
                completionHandler(model, responseObj.error);
            }
        }
    }];
}

@end
