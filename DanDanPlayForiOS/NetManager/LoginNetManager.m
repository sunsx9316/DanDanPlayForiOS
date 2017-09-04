//
//  LoginNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LoginNetManager.h"

@implementation LoginNetManager

+ (NSURLSessionDataTask *)loginWithSource:(JHLoginSource)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(JHSearchCollection *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId.length == 0 || token.length == 0){
        completionHandler(nil, parameterNoCompletionError());
        return nil;
    }
    
    NSString *sourceStr = source == JHLoginSourceWeibo ? @"weibo" : @"qq";
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/applogin", API_PATH] parameters:@{@"source" : sourceStr, @"userid" : userId, @"accesstoken" : token} completionHandler:^(JHResponse *model) {
        
    }];
}

@end
