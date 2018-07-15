//
//  DDPErrorProtocol.h
//  TJSecurity
//
//  Created by JimHuang on 2017/6/7.
//  Copyright © 2017年 convoy. All rights reserved.
//

@protocol DDPErrorProtocol <NSObject>
/**
 错误代码
 */
@property (assign, nonatomic) NSUInteger errorCode;
/**
 错误描述
 */
@property (copy, nonatomic) NSString *errorMessage;

/**
 请求是否成功
 */
@property (assign, nonatomic) BOOL success;
@end



