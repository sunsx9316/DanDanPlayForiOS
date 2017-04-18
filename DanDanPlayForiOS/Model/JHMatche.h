//
//  JHMatche.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHMatche : JHBase
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
@property (assign, nonatomic) JHEpisodeType type;

@end
