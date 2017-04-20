//
//  JHSearch.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"
#import "JHEpisode.h"

@interface JHSearch : JHBase

/*
 Title -> name 名称
 
 */

/**
 节目类型
 */
@property (assign, nonatomic) JHEpisodeType type;

@property (strong, nonatomic) NSArray <JHEpisode *>*episodes;
@end
