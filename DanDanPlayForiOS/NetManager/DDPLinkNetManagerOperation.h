//
//  DDPLinkNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  连接电脑端

#import "DDPBaseNetManager.h"
#import "DDPLinkWelcome.h"
#import "DDPLinkInfo.h"
#import "DDPLinkDownloadTaskCollection.h"
#import "DDPLibraryCollection.h"

//控制下载文件状态
typedef NSString * JHControlLinkTaskMethod NS_STRING_ENUM;
//控制视频状态
typedef NSString * JHControlVideoMethod NS_STRING_ENUM;

FOUNDATION_EXPORT JHControlLinkTaskMethod JHControlLinkTaskMethodStart;
FOUNDATION_EXPORT JHControlLinkTaskMethod JHControlLinkTaskMethodPause;
FOUNDATION_EXPORT JHControlLinkTaskMethod JHControlLinkTaskMethodDelete;


FOUNDATION_EXPORT JHControlVideoMethod JHControlVideoMethodPlay;
FOUNDATION_EXPORT JHControlVideoMethod JHControlVideoMethodStop;
FOUNDATION_EXPORT JHControlVideoMethod JHControlVideoMethodPause;
FOUNDATION_EXPORT JHControlVideoMethod JHControlVideoMethodNext;
FOUNDATION_EXPORT JHControlVideoMethod JHControlVideoMethodPrevious;

@interface DDPLinkNetManagerOperation : NSObject

/**
 尝试连接

 @param ipAdress ip
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkWithIpAdress:(NSString *)ipAdress
                     completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPLinkWelcome))completionHandler;

/**
 新增下载任务

 @param ipAdress ip
 @param magnet 磁力链
 @param completionHandler 完成回掉
 @return 任务
 */
+ (NSURLSessionDataTask *)linkAddDownloadWithIpAdress:(NSString *)ipAdress
                                               magnet:(NSString *)magnet
                         completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPLinkDownloadTask))completionHandler;

/**
 控制音量

 @param ipAdress ip
 @param volume 音量 0~100
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkChangeWithIpAdress:(NSString *)ipAdress
                                          volume:(NSUInteger)volume
                                    completionHandler:(DDPErrorCompletionAction)completionHandler;
/**
 控制进度
 
 @param ipAdress ip
 @param time 跳转时间 整数，范围0-max。time值的单位为毫秒，例如传入12345代表将视频跳转到第12.345秒处
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkChangeWithIpAdress:(NSString *)ipAdress
                                          time:(NSUInteger)time
                               completionHandler:(DDPErrorCompletionAction)completionHandler;


/**
 控制视频

 @param ipAdress ip
 @param method 方式
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkControlWithIpAdress:(NSString *)ipAdress
                                           method:(JHControlVideoMethod)method
                                completionHandler:(DDPErrorCompletionAction)completionHandler;

/**
 获取当前播放的媒体信息

 @param ipAdress ip
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkGetVideoInfoWithIpAdress:(NSString *)ipAdress
                                     completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPLibrary))completionHandler;

/**
 控制下载的文件

 @param ipAdress ip
 @param taskId 任务id
 @param method 控制方式
 @param forceDelete 是否删除源文件
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkControlDownloadWithIpAdress:(NSString *)ipAdress
                                                   taskId:(NSString *)taskId
                                                   method:(JHControlLinkTaskMethod)method
                                              forceDelete:(BOOL)forceDelete
                                    completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPLinkDownloadTask))completionHandler;

/**
 获取下载的任务列表

 @param ipAdress ip
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkDownloadListWithIpAdress:(NSString *)ipAdress
                                                   completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPLinkDownloadTaskCollection))completionHandler;


/**
 媒体库

 @param ipAdress id
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)linkLibraryWithIpAdress:(NSString *)ipAdress
                                     completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPLibraryCollection))completionHandler;

@end
