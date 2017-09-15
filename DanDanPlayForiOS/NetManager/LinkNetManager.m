//
//  LinkNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LinkNetManager.h"

JHControlLinkTaskMethod JHControlLinkTaskMethodStart = @"start";
JHControlLinkTaskMethod JHControlLinkTaskMethodPause = @"pause";
JHControlLinkTaskMethod JHControlLinkTaskMethodDelete = @"delete";

@implementation LinkNetManager

+ (NSURLSessionDataTask *)linkWithIpAdress:(NSString *)ipAdress
                         completionHandler:(void(^)(JHLinkWelcome *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (ipAdress.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/%@/welcome", ipAdress, LINK_API_INDEX] parameters:nil completionHandler:^(JHResponse *model) {
        completionHandler([JHLinkWelcome yy_modelWithJSON:model.responseObject], model.error);
    }];
}

+ (NSURLSessionDataTask *)linkAddDownloadWithIpAdress:(NSString *)ipAdress
                                               magnet:(NSString *)magnet
                                    completionHandler:(void(^)(JHLinkDownloadTask *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    //编码最后一段
    NSMutableArray<NSString *>*parameters = [[magnet componentsSeparatedByString:@":"] mutableCopy];
    NSMutableString *str = [[NSMutableString alloc] init];
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:parameters.lastObject]) {
            [str appendFormat:@"%@", [obj stringByURLEncode]];
        }
        else {
            [str appendFormat:@"%@:", obj];
        }
    }];
    magnet = str;
    
    if (ipAdress.length == 0 || magnet.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/%@/download/tasks/add", ipAdress, LINK_API_INDEX] parameters:@{@"magnet" : magnet} completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else if (model.responseObject == nil) {
            completionHandler(nil, jh_creatDownloadTaskFailError());
        }
        else {
            completionHandler([JHLinkDownloadTask yy_modelWithJSON:model.responseObject], model.error);
        }
    }];
}

+ (NSURLSessionDataTask *)linkControlDownloadWithIpAdress:(NSString *)ipAdress
                                                   taskId:(NSString *)taskId
                                                   method:(JHControlLinkTaskMethod)method
                                              forceDelete:(BOOL)forceDelete
                                        completionHandler:(void(^)(JHLinkDownloadTask *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (ipAdress.length == 0 || taskId.length == 0 || method.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/%@/download/tasks/%@/%@", ipAdress, LINK_API_INDEX, taskId, method] parameters:@{@"remove" : @(forceDelete)} completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else if (model.responseObject == nil) {
            completionHandler(nil, jh_creatDownloadTaskFailError());
        }
        else {
            completionHandler([JHLinkDownloadTask yy_modelWithJSON:model.responseObject], model.error);
        }
    }];
}

+ (NSURLSessionDataTask *)linkDownloadListWithIpAdress:(NSString *)ipAdress
                                     completionHandler:(void(^)(JHLinkDownloadTaskCollection *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (ipAdress.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/%@/download/tasks", ipAdress, LINK_API_INDEX] parameters:nil completionHandler:^(JHResponse *model) {
        JHLinkDownloadTaskCollection *collection = [[JHLinkDownloadTaskCollection alloc] init];
        collection.collection = [NSArray yy_modelArrayWithClass:[JHLinkDownloadTask class] json:model.responseObject].mutableCopy;
        completionHandler(collection, model.error);
    }];
}

+ (NSURLSessionDataTask *)linkLibraryWithIpAdress:(NSString *)ipAdress
                                completionHandler:(void(^)(JHLibraryCollection *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (ipAdress.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/%@/library", ipAdress, LINK_API_INDEX] parameters:nil completionHandler:^(JHResponse *model) {
        JHLibraryCollection *collection = [[JHLibraryCollection alloc] init];
        collection.collection = [NSArray yy_modelArrayWithClass:[JHLibrary class] json:model.responseObject].mutableCopy;
        completionHandler(collection, model.error);
    }];
}

@end
