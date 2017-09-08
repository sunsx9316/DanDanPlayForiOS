//
//  LoginNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LoginNetManager.h"

@implementation LoginNetManager

+ (NSURLSessionDataTask *)loginWithSource:(JHUserType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(JHUser *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId.length == 0 || token.length == 0){
        completionHandler(nil, parameterNoCompletionError());
        return nil;
    }
    
    NSString *sourceStr = jh_userTypeToString(source);
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/applogin/%@", API_PATH, sourceStr] parameters:@{@"userid" : userId, @"accesstoken" : token} completionHandler:^(JHResponse *model) {
        completionHandler([JHUser yy_modelWithJSON:model.responseObject], model.error);
    }];
}

@end
