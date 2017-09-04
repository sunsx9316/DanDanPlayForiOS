//
//  LoginNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"

typedef NS_ENUM(NSUInteger, JHLoginSource) {
    JHLoginSourceWeibo,
    JHLoginSourceQQ
};

@interface LoginNetManager : BaseNetManager

+ (NSURLSessionDataTask *)loginWithSource:(JHLoginSource)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(JHSearchCollection *responseObject, NSError *error))completionHandler;


@end
