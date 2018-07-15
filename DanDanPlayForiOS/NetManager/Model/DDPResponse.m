//
//  DDPResponse.m
//  BaseProject
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPResponse.h"

@implementation DDPResponse
@synthesize errorMessage = _errorMessage;
@synthesize success = _success;
@synthesize errorCode = _errorCode;


- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error {
    if (self = [super init]) {
        _responseObject = responseObject;
        
        if (error) {
            _error = error;
        }
        else {
            [self yy_modelSetWithJSON:responseObject];
            
            if ([responseObject isKindOfClass:[NSDictionary class]] &&
                responseObject[@"success"] &&
                self.success == false) {
                NSString *errorMsg = self.errorMessage ?: @"网络错误";
                self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
            }
        }
    }
    return self;
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"errorMessage" : @"ErrorMessage",
             @"success" : @[@"Success", @"success"],
             };
}

@end
