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
            let collection = [DDPFilterCollection yy_modelWithJSON:responseObj.responseObject];
            [collection.collection enumerateObjectsUsingBlock:^(DDPFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.cloudRule = YES;
            }];
            completionHandler(collection, responseObj.error);
        }
    }];
}
@end
