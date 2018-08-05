//
//  DDPLinkNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkNetManagerOperation.h"

JHControlLinkTaskMethod JHControlLinkTaskMethodStart = @"start";
JHControlLinkTaskMethod JHControlLinkTaskMethodPause = @"pause";
JHControlLinkTaskMethod JHControlLinkTaskMethodDelete = @"delete";


JHControlVideoMethod JHControlVideoMethodPlay = @"play";
JHControlVideoMethod JHControlVideoMethodStop = @"stop";
JHControlVideoMethod JHControlVideoMethodPause = @"pause";
JHControlVideoMethod JHControlVideoMethodNext = @"next";
JHControlVideoMethod JHControlVideoMethodPrevious = @"previous";

@implementation DDPLinkNetManagerOperation

+ (NSURLSessionDataTask *)linkWithIpAdress:(NSString *)ipAdress
                         completionHandler:(void(^)(DDPLinkWelcome *responseObject, NSError *error))completionHandler {
    
    if (ipAdress.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/welcome", ipAdress, LINK_API_INDEX];
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPLinkWelcome yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)linkAddDownloadWithIpAdress:(NSString *)ipAdress
                                               magnet:(NSString *)magnet
                                    completionHandler:(void(^)(DDPLinkDownloadTask *responseObject, NSError *error))completionHandler {
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
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/download/tasks/add", ipAdress, LINK_API_INDEX];
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:@{@"magnet" : magnet}
                                          completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else if (responseObj.responseObject == nil) {
            if (completionHandler) {
                completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
            }
        }
        else {
            if (completionHandler) {
                completionHandler([DDPLinkDownloadTask yy_modelWithJSON:responseObj.responseObject], responseObj.error);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)linkControlDownloadWithIpAdress:(NSString *)ipAdress
                                                   taskId:(NSString *)taskId
                                                   method:(JHControlLinkTaskMethod)method
                                              forceDelete:(BOOL)forceDelete
                                        completionHandler:(void(^)(DDPLinkDownloadTask *responseObject, NSError *error))completionHandler {
    if (ipAdress.length == 0 || taskId.length == 0 || method.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/download/tasks/%@/%@", ipAdress, LINK_API_INDEX, taskId, method];
    NSDictionary *parameters = @{@"remove" : @(forceDelete)};
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:parameters
                                          completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else if (responseObj.responseObject == nil) {
            if (completionHandler) {
                completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
            }
        }
        else {
            if (completionHandler) {
                completionHandler([DDPLinkDownloadTask yy_modelWithJSON:responseObj.responseObject], responseObj.error);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)linkDownloadListWithIpAdress:(NSString *)ipAdress
                                     completionHandler:(void(^)(DDPLinkDownloadTaskCollection *responseObject, NSError *error))completionHandler {
    
    if (ipAdress.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/download/tasks", ipAdress, LINK_API_INDEX];
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        DDPLinkDownloadTaskCollection *collection = [[DDPLinkDownloadTaskCollection alloc] init];
        collection.collection = [NSArray yy_modelArrayWithClass:[DDPLinkDownloadTask class] json:responseObj.responseObject].mutableCopy;
        if (completionHandler) {
            completionHandler(collection, responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)linkChangeWithIpAdress:(NSString *)ipAdress
                                          volume:(NSUInteger)volume
                               completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (ipAdress.length == 0) {
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/control/volume/%lu", ipAdress, LINK_API_INDEX, (unsigned long)volume];
    
    DDPBaseNetManagerSerializerType serializerType = DDPBaseNetManagerSerializerTypeJSON;
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:serializerType
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler(responseObj.error);
                                              }
                                          }];
}

+ (NSURLSessionDataTask *)linkChangeWithIpAdress:(NSString *)ipAdress
                                            time:(NSUInteger)time
                               completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (ipAdress.length == 0) {
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/control/seek/%lu", ipAdress, LINK_API_INDEX, (unsigned long)time];
    
    DDPBaseNetManagerSerializerType serializerType = DDPBaseNetManagerSerializerTypeJSON;
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:serializerType
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler(responseObj.error);
                                              }
                                          }];
}

+ (NSURLSessionDataTask *)linkControlWithIpAdress:(NSString *)ipAdress
                                           method:(JHControlVideoMethod)method
                                completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (ipAdress.length == 0 || method.length == 0) {
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/control/%@", ipAdress, LINK_API_INDEX, method];
    
    DDPBaseNetManagerSerializerType serializerType = DDPBaseNetManagerSerializerTypeJSON;
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:serializerType
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler(responseObj.error);
                                              }
                                          }];
}

+ (NSURLSessionDataTask *)linkGetVideoInfoWithIpAdress:(NSString *)ipAdress
                                     completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPLibrary))completionHandler {
    if (ipAdress.length == 0) {
        if (completionHandler) {
            completionHandler(nil , DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/current/video", ipAdress, LINK_API_INDEX];
    
    DDPBaseNetManagerSerializerType serializerType = DDPBaseNetManagerSerializerTypeJSON;
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:serializerType
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler([DDPLibrary yy_modelWithJSON:responseObj.responseObject], responseObj.error);
                                              }
                                          }];
}

+ (NSURLSessionDataTask *)linkLibraryWithIpAdress:(NSString *)ipAdress
                                completionHandler:(void(^)(DDPLibraryCollection *responseObject, NSError *error))completionHandler {
    
    if (ipAdress.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/library", ipAdress, LINK_API_INDEX];
    
    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:nil
                                          completionHandler:^(DDPResponse *responseObj) {
        DDPLibraryCollection *collection = [[DDPLibraryCollection alloc] init];
        collection.collection = [NSArray yy_modelArrayWithClass:[DDPLibrary class] json:responseObj.responseObject].mutableCopy;
        if (completionHandler) {
            completionHandler(collection, responseObj.error);
        }
    }];
}

@end
