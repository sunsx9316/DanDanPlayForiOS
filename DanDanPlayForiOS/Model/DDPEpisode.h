//
//  DDPEpisode.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@class DDPLinkFile;
@interface DDPEpisode : DDPBase

/**
 Id -> identity 节目id
 Title -> name 节目名称
 */

@property (assign, nonatomic) BOOL isOnAir;
@property (strong, nonatomic) NSDate *lastWatchDate;
@property (strong, nonatomic, readonly) NSString *lastWatchDateString;
//@property (copy, nonatomic) NSString *time;

#pragma mark - 自定义属性

/**
 是否有本地视频关联
 */
@property (strong, nonatomic) DDPLinkFile *linkFile;
@end
