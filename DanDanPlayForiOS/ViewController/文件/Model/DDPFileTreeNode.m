//
//  DDPFileTreeNode.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileTreeNode.h"

@implementation DDPFileTreeNode

- (NSMutableArray<DDPFileTreeNode *> *)subItems {
    if (_subItems == nil) {
        _subItems = [NSMutableArray array];
    }
    return _subItems;
}

@end
