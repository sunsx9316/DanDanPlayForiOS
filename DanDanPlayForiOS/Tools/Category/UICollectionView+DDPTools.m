//
//  UICollectionView+DDPTools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "UICollectionView+DDPTools.h"

@implementation UICollectionView (DDPTools)


- (void)registerCellFromClass:(Class)cellClass {
    if (cellClass == nil) {
        return;
    }
    
    [self registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
}

- (void)registerCellFromXib:(Class)cellClass {
    NSString *nibName = NSStringFromClass(cellClass);
    [self registerNib:[cellClass loadNib] forCellWithReuseIdentifier:nibName];
}

- (UICollectionViewCell * _Nullable)dequeueReusableCellWithClass:(Class)cellClass forIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
}

@end
