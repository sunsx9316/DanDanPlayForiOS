//
//  SearchNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "SearchNetManager.h"

@implementation SearchNetManager
+ (NSURLSessionDataTask *)searchOfficialWithKeyword:(NSString *)keyword episode:(NSUInteger)episode completionHandler:(void(^)(JHSearchCollection *responseObject, NSError *error))completionHandler {
    if (!keyword.length) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = nil;
    if (episode == 0) {
        path = [NSString stringWithFormat:@"%@/searchall/%@", API_PATH, [keyword stringByURLEncode]];
    }
    else {
        path = [NSString stringWithFormat:@"%@/searchall/%@/%lu", API_PATH, [keyword stringByURLEncode], (unsigned long)episode];
    }
    
    return [self GETWithPath:path parameters:nil completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHSearchCollection yy_modelWithDictionary:model.responseObject], model.error);
        }
    }];
}

+ (NSURLSessionDataTask *)searchBiliBiliWithkeyword:(NSString *)keyword completionHandler:(void(^)(JHBiliBiliSearchResult *responseObject, NSError *error))completionHandler {
    
    if (!keyword.length) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    return [self GETWithPath:@"http://biliproxy.chinacloudsites.cn/search" parameters:@{@"keyword" : keyword} completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHBiliBiliSearchResult yy_modelWithJSON:model.responseObject], model.error);
        }
    }];
}

+ (NSURLSessionDataTask *)searchBiliBiliSeasonInfoWithSeasonId:(NSUInteger)seasonId completionHandler:(void(^)(JHBiliBiliBangumiCollection *responseObject, NSError *error))completionHandler {
    
    if (seasonId == 0) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"http://bangumi.bilibili.com/jsonp/seasoninfo/%lu.ver?", (unsigned long)seasonId];
    
    return [self GETDataWithPath:path parameters:nil completionHandler:^(JHResponse *model) {
        if ([model.responseObject isKindOfClass:[NSData class]]) {
            NSString *tempStr = [[NSString alloc] initWithData:model.responseObject encoding:NSUTF8StringEncoding];
            NSRange range = [tempStr rangeOfString:@"\\{.*\\}" options:NSRegularExpressionSearch];
            
            if (range.location != NSNotFound) {
                tempStr = [tempStr substringWithRange:range];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[tempStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                if (completionHandler) {
                    completionHandler([JHBiliBiliBangumiCollection yy_modelWithDictionary: dic[@"result"]], err);
                }
            }
            else {
                if (completionHandler) {
                    completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
                }
            }
        }
        else {
            if (completionHandler) {
                completionHandler(nil, model.error);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)searchDMHYWithConfig:(JHDMHYSearchConfig *)config
                             completionHandler:(void(^)(JHDMHYSearchCollection *responseObject, NSError *error))completionHandler {
    if (config == nil) {
        if (completionHandler) {
            completionHandler(nil, jh_creatErrorWithCode(jh_errorCodeParameterNoCompletion));
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
    
    return [self GETWithPath:[NSString stringWithFormat:@"%@/list", API_DMHY_DOMAIN] parameters:dic completionHandler:^(JHResponse *model) {
        if (completionHandler) {
            completionHandler([JHDMHYSearchCollection yy_modelWithDictionary:model.responseObject], model.error);
        }
    }];
}

@end
