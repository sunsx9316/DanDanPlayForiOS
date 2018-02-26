//
//  DDPMatch.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPMatch : DDPBase
/**
 *  identity -> EpisodeId  分集id
    name -> EpisodeTitle : 分集名
 */

/**
 动画名
 */
@property (copy, nonatomic) NSString *animeTitle;

/**
 动画类型
 */
@property (assign, nonatomic) DDPEpisodeType type;

@end
