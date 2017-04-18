//
//  SearchNetManager.h
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHAnimeCollection.h"
#import "JHBiliBiliSearchCollection.h"
#import "JHBiliBiliBangumiCollection.h"

@interface SearchNetManager : BaseNetManager
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
+ (NSURLSessionDataTask *)searchOfficialWithKeyword:(NSString *)keyword episode:(NSUInteger)episode completionHandler:(void(^)(JHAnimeCollection *responseObject, NSError *error))completionHandler;

/**
 *  搜索b站结果
 *
 *  @param keyword  关键字
 *  @param completionHandler 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)searchBiliBiliWithkeyword:(NSString *)keyword completionHandler:(void(^)(JHBiliBiliSearchCollection *responseObject, NSError *error))completionHandler;
/**
 *  获取b站番剧详情
 *
 *  @param seasonId 番剧id
 *  @param completionHandler 回调
 *
 *  @return 任务
 */
+ (NSURLSessionDataTask *)searchBiliBiliSeasonInfoWithSeasonId:(NSUInteger)seasonId completionHandler:(void(^)(JHBiliBiliBangumiCollection *responseObject, NSError *error))completionHandler;

@end
