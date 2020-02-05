//
//  TOSMBSession+Hook.m
//  DDPlay
//
//  Created by JimHuang on 2020/2/5.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "TOSMBSession+Hook.h"
#import <YYCategories/YYCategories.h>


@implementation TOSMBSession (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSSelectorFromString(@"deviceIsOnWiFi") with:@selector(ddp_deviceIsOnWiFi)];        
    });
}

- (BOOL)ddp_deviceIsOnWiFi {
    return YES;
}

@end
