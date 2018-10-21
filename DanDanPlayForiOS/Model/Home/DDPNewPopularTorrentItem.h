//
//  DDPNewPopularTorrentItem.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//  种子资源

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewPopularTorrentItem : DDPBase

/**
 磁力链接
 */
@property (copy, nonatomic) NSString *magnet;

/**
 种子热度（100为热门种子，有可能超过100）
 */
@property (assign, nonatomic) NSInteger hot;
@end

NS_ASSUME_NONNULL_END
