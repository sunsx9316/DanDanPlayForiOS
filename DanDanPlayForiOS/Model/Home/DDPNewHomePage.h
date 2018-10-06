//
//  DDPNewHomePage.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPNewBanner.h"
#import "DDPNewBangumiQueueIntro.h"
#import "DDPNewBangumiIntro.h"
#import "DDPNewBangumiSeason.h"
#import "DDPNewPopularTorrentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewHomePage : DDPBase

/**
 公告列表
 */
@property (strong, nonatomic) NSArray <DDPNewBanner *>*banners;

/**
 未看剧集列表
 */
@property (strong, nonatomic) NSArray <DDPNewBangumiQueueIntro *>*bangumiQueueIntroList;

/**
 新番列表
 */
@property (strong, nonatomic) NSArray <DDPNewBangumiIntro *>*shinBangumiList;

/**
 动画番剧季度列表
 */
@property (strong, nonatomic) NSArray <DDPNewBangumiSeason *>*bangumiSeasons;

/**
 热门种子 
 */
@property (strong, nonatomic) NSArray <DDPNewPopularTorrentItem *>*popularTorrents;

@end

NS_ASSUME_NONNULL_END
