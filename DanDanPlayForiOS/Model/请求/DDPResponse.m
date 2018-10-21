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
                (responseObject[@"success"] || responseObject[@"Success"]) &&
                self.success == false) {
                NSString *errorMsg = self.errorMessage ?: @"网络错误";
                self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:self.errorCode userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
            }
        }
    }
    return self;
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"errorMessage" : @[@"ErrorMessage", @"errorMessage"],
             @"success" : @[@"Success", @"success"],
             @"errorCode" : @[@"errorCode", @"ErrorCode"]
             };
}

@end
