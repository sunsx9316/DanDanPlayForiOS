//
//  DDPFileTreeNode.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

typedef NS_ENUM(NSUInteger, DDPFileTreeNodeType) {
    DDPFileTreeNodeTypeSection,
    DDPFileTreeNodeTypeLocation,
    DDPFileTreeNodeTypeCollection,
};

@interface DDPFileTreeNode : DDPBase
@property (copy, nonatomic) UIImage *img;
@property (assign, nonatomic) DDPFileTreeNodeType type;
@property (assign, nonatomic, getter=isExpand) BOOL expand;

@property (strong, nonatomic) NSMutableArray <DDPFileTreeNode *>*subItems;
@end
