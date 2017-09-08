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

+ (NSURLSessionDataTask *)loginWithSource:(JHUserType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(JHUser *responseObject, NSError *error))completionHandler;


@end
