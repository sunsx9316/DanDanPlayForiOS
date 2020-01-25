//
//  DDPPlayHistory.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPEpisode.h"

@interface DDPPlayHistory : DDPBaseCollection<DDPEpisode *>
/*
 identity -> AnimeId
 name -> AnimeTitle
 collection -> Episodes
 */

@property (strong, nonatomic) NSURL *imageUrl;
@property (assign, nonatomic) BOOL isFavorite;
@property (copy, nonatomic) NSString *searchKeyword;
#pragma mark - 自定义属性
@property (assign, nonatomic) BOOL isOnAir;
@property (copy, nonatomic, readonly) NSString *playHistoryStatusString;
@end
