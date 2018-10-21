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
 作品ID
 */
@property (assign, nonatomic) NSInteger animeId;

/**
 动画类型
 */
@property (copy, nonatomic) DDPProductionType type;


/**
 类型描述
 */
@property (copy, nonatomic) NSString *typeDescription;

@end
