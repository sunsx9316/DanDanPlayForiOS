//
//  DDPLibrary.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  媒体库文件

#import "DDPBase.h"
#import "DDPFile.h"

@interface DDPLibrary : DDPBase
/*
 identity -> AnimeId
 md5 -> Hash
 Name为此视频的文件名（去除路径信息）
 */


/**
 弹幕库编号
 */
@property (assign, nonatomic) NSUInteger episodeId;

/**
 主标题
 */
@property (copy, nonatomic) NSString *animeTitle;

/**
 子标题
 */
@property (copy, nonatomic) NSString *episodeTitle;

/**
 为此视频的特征码
 */
@property (copy, nonatomic) NSString *md5;

/**
 此视频在硬盘上的完整路径
 */
@property (copy, nonatomic) NSString *path;

/**
 文件体积，单位为Byte
 */
@property (assign, nonatomic) NSUInteger size;

/**
 用户对此视频内容的打分，目前全部为0
 */
@property (assign, nonatomic) NSUInteger rate;

/**
 弹弹play媒体库收录此视频的时间 2016-12-12T00:54:14
 */
@property (copy, nonatomic) NSString *created;

/**
 上次使用弹弹play播放此视频的时间
 */
@property (copy, nonatomic) NSString *lastPlay;

/**
 视频时长，单位为秒
 */
@property (assign, nonatomic) NSUInteger duration;


/**
 播放器使用的id
 */
@property (copy, nonatomic) NSString *playId;

#pragma mark -  /api/v1/current/video 返回
/**
 为当前进度，取值范围0-1；
 */
@property (assign, nonatomic) CGFloat position;

/**
 为当前视频是否支持跳转进度，部分流媒体视频和直播视频不支持跳转；
 */
@property (assign, nonatomic) BOOL seekable;

/**
 当前播放器声音大小，取值范围0-100
 */
@property (assign, nonatomic) NSUInteger volume;


/**
 当前播放器状态 旧版本可能不存在 所以需要判空 Bool
 */
@property (strong, nonatomic) NSNumber *playing;

#pragma mark - 自定义属性
@property (assign, nonatomic) DDPFileType fileType;

@end
