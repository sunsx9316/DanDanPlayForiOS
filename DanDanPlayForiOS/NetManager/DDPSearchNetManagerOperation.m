//
//  DDPSearchNetManagerOperation.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPSearchNetManagerOperation.h"
#import "DDPSharedNetManager.h"

@implementation DDPSearchNetManagerOperation
+ (NSURLSessionDataTask *)searchOfficialWithKeyword:(NSString *)keyword
                                            episode:(NSUInteger)episode completionHandler:(void (^)(DDPSearchCollection *, NSError *))completionHandler {
    if (!keyword.length) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/search/episodes", [DDPMethod apiNewPath]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"anime"] = keyword;
    if (episode != 0) {
        dic[@"episode"] = @(episode);
    }
    
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:dic
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPSearchCollection yy_modelWithDictionary:responseObj.responseObject], responseObj.error);
        }
    }];
}


+ (NSURLSessionDataTask *)searchAnimateWithKeyword:(NSString *)keyword
                                              type:(DDPProductionType)type
                                 completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPSearchAnimeDetailsCollection))completionHandler {
    if (!keyword.length) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/search/anime", [DDPMethod apiNewPath]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"keyword"] = keyword;
    dic[@"type"] = type;
    
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:dic
                                          completionHandler:^(DDPResponse *responseObj) {
                                              if (completionHandler) {
                                                  completionHandler([DDPSearchAnimeDetailsCollection yy_modelWithDictionary:responseObj.responseObject], responseObj.error);
                                              }
                                          }];
}

#if DDPAPPTYPE != 1
+ (NSURLSessionDataTask *)searchBiliBiliWithkeyword:(NSString *)keyword completionHandler:(void (^)(DDPBiliBiliSearchResult *, NSError *))completionHandler {
    if (!keyword.length) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = @"http://biliproxy.chinacloudsites.cn/search";
    NSDictionary *parameters = @{@"keyword" : keyword};
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:parameters
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPBiliBiliSearchResult yy_modelWithJSON:responseObj.responseObject], responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)searchBiliBiliSeasonInfoWithKeyWord:(NSString *)keyWord
                                            completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPBiliBiliBangumiCollection))completionHandler {
    return nil;
//    if (seasonId == 0) {
//        if (completionHandler) {
//            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
//        }
//        return nil;
//    }
//
//    NSString *path = [NSString stringWithFormat:@"http://bangumi.bilibili.com/jsonp/seasoninfo/%lu.ver?", (unsigned long)seasonId];
//
//    return [[DDPBaseNetManager shareNetManager] GETWithPath:path
//                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
//                                                 parameters:nil
//                                          completionHandler:^(DDPResponse *responseObj) {
//        if ([responseObj.responseObject isKindOfClass:[NSData class]]) {
//            NSString *tempStr = [[NSString alloc] initWithData:responseObj.responseObject encoding:NSUTF8StringEncoding];
//            NSRange range = [tempStr rangeOfString:@"\\{.*\\}" options:NSRegularExpressionSearch];
//
//            if (range.location != NSNotFound) {
//                tempStr = [tempStr substringWithRange:range];
//                NSError *err;
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[tempStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
//                if (completionHandler) {
//                    completionHandler([DDPBiliBiliBangumiCollection yy_modelWithDictionary: dic[@"result"]], err);
//                }
//            }
//            else {
//                if (completionHandler) {
//                    completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
//                }
//            }
//        }
//        else {
//            if (completionHandler) {
//                completionHandler(nil, responseObj.error);
//            }
//        }
//    }];
}

+ (NSURLSessionDataTask *)searchDMHYWithConfig:(DDPDMHYSearchConfig *)config completionHandler:(void (^)(DDPDMHYSearchCollection *, NSError *))completionHandler {
    if (config == nil) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (config.keyword.length) {
        dic[@"keyword"] = config.keyword;
    }
    
    if (config.episodeType != 0) {
        dic[@"type"] = @(config.episodeType);
    }
    
    if (config.subGroupId != 0) {
        dic[@"subgroup"] = @(config.subGroupId);
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/list", API_DMHY_DOMAIN];
    
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path
                                             serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                 parameters:dic
                                          completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler([DDPDMHYSearchCollection yy_modelWithDictionary:responseObj.responseObject], responseObj.error);
        }
    }];
}

#endif

@end
