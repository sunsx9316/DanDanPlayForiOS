//
//  DDPNewBangumiIntro.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//  新番列表

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewBangumiIntro : DDPBase

/*
 identity -> animeId 作品编号
 name -> animeTitle 作品标题
 */


/**
 海报图片地址
 */
@property (strong, nonatomic) NSURL *imageUrl;

/**
 搜索关键词
 */
@property (copy, nonatomic) NSString *searchKeyword;

/**
 是否正在连载中
 */
@property (assign, nonatomic) BOOL isOnAir;

/**
 周几上映，0代表周日，1-6代表周一至周六 
 */
@property (assign, nonatomic) NSInteger airDay;

/**
 当前用户是否已关注（无论是否为已弃番等附加状态）
 */
@property (assign, nonatomic) BOOL isFavorited;

/**
 是否为限制级别的内容（例如属于R18分级）
 */
@property (assign, nonatomic) BOOL isRestricted;

/**
 番剧综合评分（综合多个来源的评分求出的加权平均值，0-10分）
 */
@property (assign, nonatomic) CGFloat rating;

@end

NS_ASSUME_NONNULL_END
