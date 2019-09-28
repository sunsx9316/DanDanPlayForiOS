//
//  DDPVersion.h
//  DDPlay_ToMac
//
//  Created by JimHuang on 2019/9/26.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN
/*
 desc -> 升级详情
 */
@interface DDPVersion : DDPBase
/**
 *  升级版本 如 201909271
 */
@property (copy, nonatomic) NSString *version;

/// 短版本 如：3.0
@property (copy, nonatomic) NSString *shortVersion;

/**
 *  版本的哈希值
 */
@property (copy, nonatomic) NSString *md5;

/// 下载地址
@property (strong, nonatomic) NSURL *url;

/// 是否强制更新
@property (assign, nonatomic) BOOL forceUpdate;


#pragma mark - 本地属性

/// 是否需要升级
@property (assign, nonatomic, readonly) BOOL shouldUpdate;
@end

NS_ASSUME_NONNULL_END
