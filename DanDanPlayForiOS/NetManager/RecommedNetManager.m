//
//  RecommedNetManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/3/11.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "RecommedNetManager.h"

@implementation RecommedNetManager
+ (NSURLSessionDataTask *)recommedInfoWithCompletionHandler:(void(^)(JHHomePage *responseObject, NSError *error))completionHandler {
    
    if (completionHandler == nil) {
        return nil;
    }
    
    JHUser *user = [CacheManager shareCacheManager].user;
    
    return [self GETDataWithPath:[NSString stringWithFormat:@"%@/homepage?userId=%lu&token=%@", API_PATH, (unsigned long)user.identity, user.token] parameters:nil headerField:@{@"Accept" : @"application/xml"} completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            NSDictionary *dic = [NSDictionary dictionaryWithXML:model.responseObject];
            JHHomePage *homePageModel = [JHHomePage yy_modelWithJSON:dic];
            completionHandler(homePageModel, model.error);
        }
    }];
}
@end
