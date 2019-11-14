//
//  DDPVideoModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPMediaItemProtocal.h"

//匹配的长度 16M
#define MEDIA_MATCH_LENGTH 16777216


@class DDPFile;

@interface DDPVideoModel : DDPBase<DDPMediaItemProtocol>

/*
 文件名 :name
 
 */

/**
 *  初始化
 *
 *  @param fileURL 文件路径
 *
 *  @return self
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL;

/**
 文件路径
 */
@property (copy, nonatomic, readonly) NSURL *fileURL;

/**
 带后缀的文件名
 */
@property (copy, nonatomic, readonly) NSString *fileNameWithPathExtension;

/**
 文件前16MB(16x1024x1024Byte)数据的32位MD5结果，不区分大小写
 */
@property (copy, nonatomic, readonly) NSString *fileHash;

/**
 文件总长度，单位为Byte。
 */
@property (assign, nonatomic, readonly) NSUInteger length;

/**
 快速hash 文件名的hash值
 */
@property (copy, nonatomic, readonly) NSString *quickHash;

/**
 弹幕
 */
@property (strong, nonatomic) DDPDanmakuCollection *danmakus;

/**
 文件模型
 */
@property (weak, nonatomic) __kindof DDPFile *file;

/**
 匹配名称
 */
@property (strong, nonatomic) NSString *matchName;

/**
 是否缓存了hash值
 */
@property (assign, nonatomic, getter=isCacheHash) BOOL cacheHash;
@end
