//
//  DDPWebDAVLoginInfo.h
//  DDPlay
//
//  Created by JimHuang on 2020/4/26.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPWebDAVLoginInfo : DDPBase
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong, readonly) NSURL *url;
@end

NS_ASSUME_NONNULL_END
