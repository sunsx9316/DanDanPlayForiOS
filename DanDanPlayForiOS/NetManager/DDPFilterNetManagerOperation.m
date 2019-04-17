//
//  DDPFilterNetManagerOperation.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/2/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPFilterNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPFilterNetManagerOperation
+ (NSURLSessionDataTask *)cloudFilterListWithCompletionHandler:(void (^)(DDPFilterCollection *, NSError *))completionHandler {
    
    NSString *path = @"https://api.acplay.net/config/filter.xml";
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeXML
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPFilterCollection yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}
@end
