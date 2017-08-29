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
@end
