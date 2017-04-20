//
//  CacheManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JHUser;
@interface CacheManager : NSObject

//当前分析的视频模型
@property (strong, nonatomic) VideoModel *currentVideoModel;

//列表中的视频
@property (strong, nonatomic) NSMutableArray <VideoModel *>*videoModels;
@property (strong, nonatomic) NSArray <JHFilter *>*danmakuFilters;
@property (assign, nonatomic) NSUInteger danmakuCacheTime;
- (void)addDanmakuFilter:(JHFilter *)danmakuFilter;
- (void)removeDanmakuFilter:(JHFilter *)danmakuFilter;

@property (strong, nonatomic) JHUser *user;

+ (instancetype)shareCacheManager;

@end
