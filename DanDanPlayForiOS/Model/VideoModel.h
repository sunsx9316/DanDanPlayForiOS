//
//  VideoModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@class VLCMedia, JHBaseDanmaku, JHFile;
@interface VideoModel : JHBase
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
 文件名
 */
@property (copy, nonatomic, readonly) NSString *fileName;

/**
 带后缀的文件名
 */
@property (copy, nonatomic, readonly) NSString *fileNameWithPathExtension;

/**
 文件前16MB(16x1024x1024Byte)数据的32位MD5结果，不区分大小写
 */
@property (copy, nonatomic, readonly) NSString *md5;

/**
 文件总长度，单位为Byte。
 */
@property (assign, nonatomic, readonly) NSUInteger length;

/**
 快速hash 文件名的hash值
 */
@property (copy, nonatomic, readonly) NSString *quickHash;

/**
 视频模型
 */
@property (strong, nonatomic, readonly) VLCMedia *media;

/**
 弹幕
 */
@property (strong, nonatomic) JHDanmakuCollection *danmakus;

/**
 文件模型
 */
@property (strong, nonatomic) JHFile *file;
@end
