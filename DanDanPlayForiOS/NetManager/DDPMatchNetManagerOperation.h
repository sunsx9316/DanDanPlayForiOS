//
//  DDPMatchNetManagerOperation.h
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPVideoModel.h"
#import "DDPMatchCollection.h"
#import "DDPUser.h"

@interface DDPMatchNetManagerOperation : NSObject

/**
 使用指定的文件名、Hash、文件长度信息寻找文件可能对应的节目信息。

 @param model 视频模型
 
 1. fileName 视频文件名，不包含文件夹名称和扩展名，特殊字符需进行转义
 2. hash 文件前16MB(16x1024x1024Byte)数据的32位MD5结果
 3. length 文件总长度，单位为Byte
 
 @param completionHandler 回调
 @return 任务
 */

+ (NSURLSessionDataTask *)matchVideoModel:(DDPVideoModel *)model
                        completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPMatchCollection))completionHandler;

/**
 提交文件匹配关联

 @param model 视频模型
 @param user 用户
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)matchEditMatchVideoModel:(DDPVideoModel *)model
                                                  user:(DDPUser *)user
                        completionHandler:(DDPErrorCompletionAction)completionHandler;

/**
 快速适配视频 返回弹幕数组

 @param model 视频模型
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)fastMatchVideoModel:(DDPVideoModel *)model
                              progressHandler:(DDPProgressAction)progressHandler
                            completionHandler:(DDP_COLLECTION_RESPONSE_ACTION(DDPDanmakuCollection))completionHandler;
@end
