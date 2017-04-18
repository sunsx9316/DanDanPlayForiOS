//
//  JHResponse.m
//  BaseProject
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHResponse.h"

@implementation JHResponse
- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error {
    if (self = [super init]) {
        _responseObject = responseObject;
        _error = error;
    }
    return self;
}
@end
