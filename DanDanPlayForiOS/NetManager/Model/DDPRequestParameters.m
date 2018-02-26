//
//  DDPRequestParameters.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/7.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPRequestParameters.h"

@implementation DDPRequestParameters

- (instancetype)initWithType:(DDPBaseNetManagerSerializerType)type parameters:(id)parameters {
    if (self = [super init]) {
        self.serializerType = type;
        self.parameters = parameters;
    }
    return self;
}

@end
