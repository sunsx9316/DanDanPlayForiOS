//
//  JHEpisode.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHEpisode : JHBase

/**
 Id -> idntity 节目id
 Title -> name 节目名称
 */

@property (assign, nonatomic) BOOL isOnAir;
@property (copy, nonatomic) NSString *time;
@end
