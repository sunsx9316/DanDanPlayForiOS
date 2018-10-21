//
//  DDPSearchAnimeDetails.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPSearchAnimeDetails : DDPBase

/*
 identity -> animeId
 name -> animeTitle
 */

@property (copy, nonatomic) DDPProductionType type;
@property (copy, nonatomic) NSString *typeDescription;
@property (strong, nonatomic) NSURL *imageUrl;
@property (copy, nonatomic) NSString *startDate;
@property (assign, nonatomic) NSUInteger episodeCount;
@property (assign, nonatomic) CGFloat rating;
@property (assign, nonatomic) BOOL isFavorited;

@end

NS_ASSUME_NONNULL_END
