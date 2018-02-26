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

typedef NSString * JHControlLinkTaskMethod;

FOUNDATION_EXPORT JHControlLinkTaskMethod JHControlLinkTaskMethodStart;
FOUNDATION_EXPORT JHControlLinkTaskMethod JHControlLinkTaskMethodPause;
FOUNDATION_EXPORT JHControlLinkTaskMethod JHControlLinkTaskMethodDelete;

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
 控制文件

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
