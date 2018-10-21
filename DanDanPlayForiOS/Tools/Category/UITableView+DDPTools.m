//
//  UITableView+DDPTools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/1.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "UITableView+DDPTools.h"

@implementation UITableView (DDPTools)

- (void)registerCellFromClass:(Class)cellClass {
    if (cellClass == nil) {
        return;
    }
    
    [self registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

- (void)registerCellFromXib:(Class)cellClass {
    NSString *nibName = NSStringFromClass(cellClass);
    [self registerNib:[cellClass loadNib] forCellReuseIdentifier:nibName];
}

- (UITableViewCell * _Nullable)dequeueReusableCellWithClass:(Class)cellClass forIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
}

@end
