//
//  DDPRequestParameters.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/7.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPRequestParameters : DDPBase
@property (assign, nonatomic) DDPBaseNetManagerSerializerType serializerType;
@property (strong, nonatomic) id parameters;

- (instancetype)initWithType:(DDPBaseNetManagerSerializerType)type parameters:(id)parameters;
@end
