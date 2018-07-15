//
//  DDPRegisterResponse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPRegisterResponse.h"

@implementation DDPRegisterResponse

- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error {
    
    if (self = [super init]) {
        self.responseObject = responseObject;
        
        if (error) {
            self.error = error;
        }
        else {
            [self yy_modelSetWithJSON:responseObject];
            
            if (self.success == false) {
                self.error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"注册失败"}];
            }
        }
    }
    
    return self;
}

@end
