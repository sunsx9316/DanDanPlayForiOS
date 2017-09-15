//
//  MatchNetManager.h
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "VideoModel.h"
#import "JHMatcheCollection.h"
#import "JHUser.h"

@interface MatchNetManager : BaseNetManager

/**
 使用指定的文件名、Hash、文件长度信息寻找文件可能对应的节目信息。

 @param model 视频模型
 
 1. fileName 视频文件名，不包含文件夹名称和扩展名，特殊字符需进行转义
 2. hash 文件前16MB(16x1024x1024Byte)数据的32位MD5结果
 3. length 文件总长度，单位为Byte
 
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)matchVideoModel:(VideoModel *)model
                        completionHandler:(void(^)(JHMatcheCollection *responseObject, NSError *error))completionHandler;

/**
 更改匹配模型

 @param model 视频模型
 @param user 用户
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)matchEditMatchVideoModel:(VideoModel *)model
                                                  user:(JHUser *)user
                        completionHandler:(void(^)(NSError *error))completionHandler;

/**
 快速适配视频 返回弹幕数组

 @param model 视频模型
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)fastMatchVideoModel:(VideoModel *)model progressHandler:(progressAction)progressHandler completionHandler:(void(^)(JHDanmakuCollection *responseObject, NSError *error))completionHandler;
@end
