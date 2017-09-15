//
//  LoginNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHUser.h"

@interface LoginNetManager : BaseNetManager

/**
 登录

 @param source 登录类型
 @param userId 用户id
 @param token 用户token
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)loginWithSource:(JHUserType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(JHUser *responseObject, NSError *error))completionHandler;


@end
