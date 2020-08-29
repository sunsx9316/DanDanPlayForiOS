//
//  DDPWebDAVLoginInfo.m
//  DDPlay
//
//  Created by JimHuang on 2020/4/26.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVLoginInfo.h"

@implementation DDPWebDAVLoginInfo

- (BOOL)isEqual:(DDPWebDAVLoginInfo *)other {
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:self.class]) {
        return NO;
    } else {
        return [self.path isEqual:other.path];
    }
}

- (NSUInteger)hash
{
    return self.path.hash;
}

- (NSURL *)url {
    return [NSURL URLWithString:self.path];
}

@end
