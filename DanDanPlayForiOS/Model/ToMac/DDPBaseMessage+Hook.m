//
//  DDPBaseMessage+Hook.m
//  DDPlay_ToMac
//
//  Created by JimHuang on 2019/9/4.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPBaseMessage+Hook.h"


@implementation DDPBaseMessage (Hook)

+ (NSString *)toApp {
    return @"ddplaymac";
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(messageTo) with:@selector(ddp_messageTo)];
    });
}

- (NSString *)ddp_messageTo {
    return [self.class toApp];
}
@end
