//
//  MatchNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "MatchNetManager.h"

@implementation MatchNetManager

+ (NSURLSessionDataTask *)GETWithVideoModel:(VideoModel *)model completionHandler:(void(^)(JHMatcheCollection *responseObject, NSError *eroor))completionHandler {
    
    NSString *hash = model.md5;
    NSUInteger length = model.length;
    NSString *fileName = model.fileName;
    
    if (!hash.length) {
        if (completionHandler) {
            completionHandler(nil, parameterNoCompletionError());
        }
        return nil;
    }
    
    if (!fileName.length) {
        fileName = @"";
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/match", API_PATH] parameters:@{@"fileName":fileName, @"hash": hash, @"length": @(length)} completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHMatcheCollection yy_modelWithDictionary: model.responseObject], model.error);
        }
    }];
}

@end
