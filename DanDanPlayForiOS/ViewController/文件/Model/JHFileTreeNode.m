//
//  JHFileTreeNode.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFileTreeNode.h"

@implementation JHFileTreeNode

- (NSMutableArray<JHFileTreeNode *> *)subItems {
    if (_subItems == nil) {
        _subItems = [NSMutableArray array];
    }
    return _subItems;
}

@end
