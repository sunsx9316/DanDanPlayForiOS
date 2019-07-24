//
//  DDPSearchNetManagerOperation.h
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPSearchCollection.h"
#import "DDPBiliBiliSearchResult.h"
#import "DDPBiliBiliBangumiCollection.h"
#import "DDPDMHYSearchCollection.h"
#import "DDPDMHYSearchConfig.h"
#import "DDPSearchAnimeDetailsCollection.h"

@interface DDPSearchNetManagerOperation : NSObject
/**
 *  官方搜索请求
 *
 *  @param keyword 动画标题，支持通过中文、日语（含罗马音）、英语搜索，至少为2个字符。
 *  @param episode   
 [可选参数]节目子标题，默认为空。
 当此值为纯数字时，将过滤搜索结果，仅保留指定集数的条目。
 当此值为“movie”时，将过滤搜索结果，仅保留剧场版条目。
 当此值为其他字符串时，将过滤搜索结果，仅保留子标题包含指定文字的条目，不建议使用。
 *  @param completionHandler  回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)searchOfficialWithKeyword:(NSString *)keyword
                                            episode:(NSUInteger)episode
                                  completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPSearchCollection))completionHandler;


/**
 搜索动画

 @param keyword 关键词
 @param type 类型
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)searchAnimateWithKeyword:(NSString *)keyword
                                            type:(DDPProductionType)type
                                  completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPSearchAnimeDetailsCollection))completionHandler;

#if DDPAPPTYPE != 1
/**
 *  搜索b站结果
 *
 *  @param keyword  关键字
 *  @param completionHandler 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)searchBiliBiliWithkeyword:(NSString *)keyword
                                  completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPBiliBiliSearchResult))completionHandler;

/**
 *  获取b站番剧详情
 *
 *  @param seasonId 番剧id
 *  @param completionHandler 回调
 *
 *  @return 任务
 */

+ (NSURLSessionDataTask *)searchBiliBiliSeasonInfoWithKeyWord:(NSString *)keyWord
                                             completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPBiliBiliBangumiCollection))completionHandler;


/**
 搜索动漫花园

 @param config 配置
 @return 任务
 */
+ (NSURLSessionDataTask *)searchDMHYWithConfig:(DDPDMHYSearchConfig *)config
                              completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPDMHYSearchCollection))completionHandler;
#endif

@end
