//
//  DDPFavorite.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  用户收藏

#import "DDPBase.h"

@interface DDPFavorite : DDPBase
/*
 identity -> AnimeId
 name -> AnimeTitle
 */


/**
 关注时间
 */
@property (copy, nonatomic) NSString *attentionTime;

/**
 图片
 */
@property (strong, nonatomic) NSURL *imageUrl;

/**
 总集数
 */
@property (assign, nonatomic) NSUInteger episodeTotal;

/**
 已看
 */
@property (assign, nonatomic) NSUInteger episodeWatched;

/**
 连载中的动画
 */
@property (assign, nonatomic) BOOL isOnAir;

@end
