//
//  FilterNetManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/2/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "FilterNetManager.h"

@implementation FilterNetManager
+ (NSURLSessionDataTask *)cloudFilterListWithCompletionHandler:(void(^)(JHFilterCollection *responseObject, NSError *error))completionHandler {
    
#ifdef DEBUG
    NSString *path = @"http://api.acplay.net:8089/config/filter.xml";
#else
    NSString *path = @"https://api.acplay.net/config/filter.xml";
#endif
    
    return [self GETDataWithPath:path parameters:nil completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHFilterCollection yy_modelWithJSON:[NSDictionary dictionaryWithXML:model.responseObject]], model.error);
        }
    }];
}
@end
