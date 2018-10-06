//
//  DDPSearch.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPEpisode.h"

@interface DDPSearch : DDPBase

/*
 Title -> name 名称
 
 */

/**
 节目类型
 */
@property (strong, nonatomic) DDPProductionType type;

/**
 类型描述
 */
@property (copy, nonatomic) NSString *typeDescription;

@property (strong, nonatomic) NSArray <DDPEpisode *>*episodes;
@end
