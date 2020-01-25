//
//  DDPCollectionCache.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPCollectionCache.h"
#import "NSURL+Tools.h"

@implementation DDPCollectionCache

- (NSUInteger)hash {
    return self.cacheType ^ self.filePath.hash;
}

- (BOOL)isEqual:(DDPCollectionCache *)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    return self.cacheType == object.cacheType && [self.filePath isEqualToString:object.filePath];
}

@end
