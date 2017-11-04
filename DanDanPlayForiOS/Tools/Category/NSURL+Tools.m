//
//  NSURL+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "NSURL+Tools.h"

@implementation NSURL (Tools)
- (NSURLRelationship)relationshipWithURL:(NSURL *)url {
    NSURLRelationship ship;
    [[NSFileManager defaultManager] getRelationship:&ship ofDirectoryAtURL:self toItemAtURL:url error:nil];
    return ship;
}

- (NSString *)relativePathWithBaseURL:(NSURL *)url {
    NSArray *rootURLArr = url.pathComponents;
    NSArray *currentURLArr = self.pathComponents;
    if (currentURLArr.count <= rootURLArr.count) {
        return nil;
    }
    
    NSArray *subArr = [currentURLArr subarrayWithRange:NSMakeRange(rootURLArr.count, currentURLArr.count - rootURLArr.count)];
    __block NSString *path = [[NSString alloc] init];
    [subArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        path = [path stringByAppendingPathComponent:obj];
    }];
    return path;
}

@end
