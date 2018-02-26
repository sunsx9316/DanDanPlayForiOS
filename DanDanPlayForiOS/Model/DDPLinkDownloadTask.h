//
//  DDPLinkDownloadTask.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"


/**
 下载状态

 - DDPLinkDownloadTaskStateStop: 已停止
 - DDPLinkDownloadTaskStatePause: 已暂停
 - DDPLinkDownloadTaskStateDownloading: 正在下载
 - DDPLinkDownloadTaskStateMaskTorrent: 正在做种
 - DDPLinkDownloadTaskStateCalculateHash: 正在计算Hash
 - DDPLinkDownloadTaskStateStoping: 正在停止
 - DDPLinkDownloadTaskStateError: 出错
 - DDPLinkDownloadTaskStateGetMetaData: 正在获取元数据
 */
typedef NS_ENUM(NSUInteger, DDPLinkDownloadTaskState) {
    DDPLinkDownloadTaskStateStop,
    DDPLinkDownloadTaskStatePause,
    DDPLinkDownloadTaskStateDownloading,
    DDPLinkDownloadTaskStateMaskTorrent,
    DDPLinkDownloadTaskStateCalculateHash,
    DDPLinkDownloadTaskStateStoping,
    DDPLinkDownloadTaskStateError,
    DDPLinkDownloadTaskStateGetMetaData,
};

@interface DDPLinkDownloadTask : DDPBase
/*
 name -> Title
 */


/**
 下载任务ID，即BTHash
 */
@property (copy, nonatomic) NSString *taskId;

/**
 下载进度，范围是0.0-1.0。可以通过此数字判断任务状态，小于1.0为未完成，大于等于1.0为已完成。
 */
@property (assign, nonatomic) CGFloat progress;

/**
 下载状态：0-已停止，1-已暂停，2-正在下载，3-正在做种，4-正在计算Hash，
 5-正在停止，6-出错，7-正在获取元数据
 */
@property (assign, nonatomic) DDPLinkDownloadTaskState state;

/**
 下载任务总共字节数
 */
@property (assign, nonatomic) NSUInteger totalBytes;

/**
 已下载的字节数
 */
@property (assign, nonatomic) NSUInteger downloadedBytes;

/**
 下载速度，单位是 Byte/s
 */
@property (assign, nonatomic) CGFloat downloadSpeed;

/**
 上传速度，单位是 Byte/s
 */
@property (assign, nonatomic) CGFloat uploadSpeed;

/**
 剩余时间，单位是秒。-1表示无法估算或任务已暂停
 */
@property (assign, nonatomic) NSInteger remainTime;

/**
 下载保存目录
 */
@property (copy, nonatomic) NSString *savePath;

/**
 不下载（被忽略）文件的列表，使用相对路径，不同文件之间用“|”符号分割，例如 1.txt|example\2.txt|3.txt
 */
@property (copy, nonatomic) NSString *ignore;

/**
 "2017-01-12T12:47:58.1776363+08:00" //任务创建时间，使用系统时区信息
 */
@property (copy, nonatomic) NSString *createdTime;
@end
