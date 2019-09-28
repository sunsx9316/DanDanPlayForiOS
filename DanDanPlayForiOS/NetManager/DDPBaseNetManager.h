//
//  DDPBaseNetManager.h
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPBatchResponse.h"
#import "YYReachability.h"
#import "DDPNetManagerDefine.h"

@protocol DDPBaseNetManagerObserver<NSObject>
@optional
- (void)netStatusChange:(YYReachability *)reachability;
@end

@interface DDPBaseNetManager : NSObject

/**
 设置JWTToken

 @param token JWTToken
 */
//- (void)resetJWTToken:(NSString *)token;

/**
 *  GET封装
 *
 *  @param path       路径
 *  @param parameters 参数
 *  @param completionHandler   完成回调
 *
 *  @return 任务
 */
- (NSURLSessionDataTask *)GETWithPath:(NSString*)path
                       serializerType:(DDPBaseNetManagerSerializerType)serializerType
                           parameters:(id)parameters
                    completionHandler:(DDPResponseCompletionAction)completionHandler;

/**
 PUT封装

 @param path 路径
 @param parameters 参数
 @param completionHandler 完成回调
 @return 任务
 */
- (NSURLSessionDataTask *)PUTWithPath:(NSString *)path
                       serializerType:(DDPBaseNetManagerSerializerType)serializerType
                           parameters:(id)parameters
                    completionHandler:(DDPResponseCompletionAction)completionHandler;

/**
 POST封装

 @param path 路径
 @param serializerType 序列化类型
 @param parameters 参数
 @param completionHandler 完成回调
 @return 任务
 */
- (NSURLSessionDataTask *)POSTWithPath:(NSString *)path
                        serializerType:(DDPBaseNetManagerSerializerType)serializerType
                            parameters:(id)parameters
                     completionHandler:(DDPResponseCompletionAction)completionHandler;

/**
 *  DELETE封装
 *
 *  @param path       路径
 *  @param HTTPBody   HTTPBody 需要发送的数据
 *  @param completionHandler   回调
 *
 *  @return 任务
 */
- (NSURLSessionDataTask *)DELETEWithPath:(NSString *)path
                          serializerType:(DDPBaseNetManagerSerializerType)serializerType
                             parameters:(id)parameters
                    completionHandler:(DDPResponseCompletionAction)completionHandler;

#if DDPAPPTYPEISMAC

/// 下载封装
/// @param path 路径
/// @param downloadProgressBlock 进度回调
/// @param destination 写入路径回调
/// @param completionHandler 完成回调
- (NSURLSessionDownloadTask *)downloadTaskWithPath:(NSString *)path
                                          progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                       destination:(NSURL *(^)(NSURL *targetPath, NSURLResponse *response))destination
                                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
#endif

/**
 *  批量GET任务
 *
 *  @param paths           路径字典
 *  @param progressBlock   进度回调
 *  @param completionHandler 完成回调
 */
- (void)batchGETWithPaths:(NSArray <NSString *>*)paths
           serializerType:(DDPBaseNetManagerSerializerType)serializerType
        editResponseBlock:(DDPBatchEditResponseObjAction)editResponseBlock
            progressBlock:(DDPProgressAction)progressBlock
        completionHandler:(DDPBatchCompletionAction)completionHandler;

- (void)addObserver:(id<DDPBaseNetManagerObserver>)observer;
- (void)removeObserver:(id<DDPBaseNetManagerObserver>)observer;
@end
