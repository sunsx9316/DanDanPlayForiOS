//
//  ParseNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHDMHYParse.h"

@interface ParseNetManager : BaseNetManager

/**
 解析动漫花园链接

 @param url 路径
 @param completionHandler 回调
 @return 任务
 */
+ (NSURLSessionDataTask *)parseDMHYWithURL:(NSString *)url
                              completionHandler:(void(^)(JHDMHYParse *responseObject, NSError *error))completionHandler;
@end
