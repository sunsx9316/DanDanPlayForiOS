//
//  DDPNewBangumiQueueIntro.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//  未看剧集

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewBangumiQueueIntro : DDPBase

/*
 identity -> animeId 作品编号
 name -> animeTitle 作品标题
 desc -> description 未看状态的说明，如“今天更新”，“昨天更新”，“有多集未看”等
 */


/**
最新一集的剧集标题
 */
@property (copy, nonatomic) NSString *episodeTitle;

/**
 剧集上映日期（无小时分钟，当地时间）
 */
@property (copy, nonatomic) NSString *airDate;

/**
 海报图片地址
 */
@property (strong, nonatomic) NSURL *imageUrl;


/**
 番剧是否在连载中
 */
@property (assign, nonatomic) BOOL isOnAir;

@end

NS_ASSUME_NONNULL_END
