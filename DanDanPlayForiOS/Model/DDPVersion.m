//
//  DDPVersion.m
//  DDPlay_ToMac
//
//  Created by JimHuang on 2019/9/26.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPVersion.h"
#import <YYCategories/YYCategories.h>

@implementation DDPVersion

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"md5" : @"hash"};
}

- (BOOL)shouldUpdate {
    let localVersion = UIApplication.sharedApplication.appBuildVersion;
    let result = [self.version compare:localVersion options:NSNumericSearch];
    return result == NSOrderedDescending;
}

@end
