//
//  DDPVideoModel+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/2/16.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPVideoModel.h"

@interface DDPVideoModel (Tools)

/**
 关联的视频Id
 */
@property (assign, nonatomic, readonly) NSUInteger relevanceEpisodeId;

/**
 关联的视频名称
 */
@property (copy, nonatomic, readonly) NSString *relevanceName;


/**
 关联的hash值
 */
@property (copy, nonatomic, readonly) NSString *relevanceHash;


/**
 上次播放时间
 */
@property (assign, nonatomic, readonly) NSInteger lastPlayTime;

- (void)lastPlayTimeWithBlock:(void(^)(NSInteger lastPlayTime))action;


@end
