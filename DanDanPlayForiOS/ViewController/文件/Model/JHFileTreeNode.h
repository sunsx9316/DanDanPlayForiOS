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
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *detail;
@property (assign, nonatomic) JHFileTreeNodeType type;

@property (strong, nonatomic) NSMutableArray <JHFileTreeNode *>*subItems;
@end
