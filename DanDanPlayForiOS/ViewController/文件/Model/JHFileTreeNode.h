//
//  JHFileTreeNode.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

typedef NS_ENUM(NSUInteger, JHFileTreeNodeType) {
    JHFileTreeNodeTypeSection,
    JHFileTreeNodeTypeLocation,
    JHFileTreeNodeTypeCollection,
};

@interface JHFileTreeNode : JHBase
@property (copy, nonatomic) UIImage *img;
@property (assign, nonatomic) JHFileTreeNodeType type;
@property (assign, nonatomic, getter=isExpand) BOOL expand;

@property (strong, nonatomic) NSMutableArray <JHFileTreeNode *>*subItems;
@end
