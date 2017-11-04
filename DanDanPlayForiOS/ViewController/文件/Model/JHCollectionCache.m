//
//  JHCollectionCache.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHCollectionCache.h"
#import "NSURL+Tools.h"

@implementation JHCollectionCache

- (NSUInteger)hash {
    return self.cacheType | self.fileURL.hash;
}

- (BOOL)isEqual:(JHCollectionCache *)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    return self.cacheType == object.cacheType && [self.fileURL.absoluteString isEqualToString:object.fileURL.absoluteString];
}

@end
