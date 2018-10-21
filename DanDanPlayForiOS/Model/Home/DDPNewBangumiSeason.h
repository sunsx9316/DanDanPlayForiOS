//
//  DDPNewBangumiSeason.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewBangumiSeason : DDPBase

/*
 name -> seasonName 季度名称
 
 */

@property (assign, nonatomic) NSUInteger year;
@property (assign, nonatomic) NSUInteger month;

@end

NS_ASSUME_NONNULL_END
