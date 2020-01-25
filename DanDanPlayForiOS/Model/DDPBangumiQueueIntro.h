//
//  DDPBangumiQueueIntro.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPBangumiEpisode.h"

@interface DDPBangumiQueueIntro : DDPBaseCollection<DDPBangumiEpisode *>
/*
 identity -> AnimeId
 name -> AnimeTitle
 desc -> Description
 collection -> Episodes[DDPBangumiEpisode]
 */


/**
 分集名
 */
@property (copy, nonatomic) NSString *episodeTitle;

/**
 发布日期
 */
@property (copy, nonatomic) NSString *airDate;

/**
 图片
 */
@property (strong, nonatomic) NSURL *imageUrl;

/**
 正在连载
 */
@property (assign, nonatomic) BOOL isOnAir;

/**
 搜索关键词
 */
@property (copy, nonatomic) NSString *searchKeyword;

/**
 上次观看时间
 */
@property (copy, nonatomic) NSString *lastWatched;
@end
