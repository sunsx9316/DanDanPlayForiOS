//
//  DDPBindingResponse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/6/14.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBindingResponse.h"

@implementation DDPBindingResponse

- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error {
    
    if (self = [super init]) {
        self.responseObject = responseObject;
        
        if (error) {
            self.error = error;
        }
        else {
            [self yy_modelSetWithJSON:responseObject];
            
            if (self.success == false) {
                self.error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"绑定失败"}];
            }
        }
    }
    
    return self;
}

@end
