//
//  DDPLoginNetManagerOperation.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import "DDPUser.h"
#import "DDPRegisterRequest.h"
#import "DDPRegisterResponse.h"

@interface DDPLoginNetManagerOperation : NSObject

/**
 登录

 @param source 登录类型
 @param userId 用户id 第三方登录时为第三方提供的id 官方登录为用户名
 @param token 用户token 第三方登录时为第三方提供的token 官方登录为用户密码
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginWithSource:(DDPUserType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPUser))completionHandler;

/**
 注册

 @param request 请求对象
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginRegisterWithRequest:(DDPRegisterRequest *)request
                        completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPRegisterResponse))completionHandler;


/**
 注册并关联第三方帐号

 @param request 请求
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginRegisterRelateToThirdPartyWithRequest:(DDPRegisterRequest *)request
                                                   completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPRegisterResponse))completionHandler;


/**
 绑定已有帐号

 @param request 请求
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginRegisterRelateOnlyWithRequest:(DDPRegisterRequest *)request
                                                   completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPRegisterResponse))completionHandler;

/**
 修改用户名

 @param userId 用户id
 @param token 用户token
 @param userName 用户名
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginEditUserNameWithUserId:(NSUInteger)userId
                                                token:(NSString *)token
                                             userName:(NSString *)userName
                                           completionHandler:(DDPErrorCompletionAction)completionHandler;
/**
 修改密码
 
 @param userId 用户id
 @param token 用户token
 @param oldPassword 原密码
 @param aNewPassword 新密码
 @param completionHandler 完成回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginEditPasswordWithUserId:(NSUInteger)userId
                                                token:(NSString *)token
                                          oldPassword:(NSString *)oldPassword
                                             aNewPassword:(NSString *)aNewPassword
                                    completionHandler:(DDPErrorCompletionAction)completionHandler;

@end
