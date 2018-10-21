//
//  UITableView+DDPTools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/1.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (DDPTools)

- (void)registerCellFromClass:(Class)cellClass;
- (void)registerCellFromXib:(Class)cellClass;
- (__kindof UITableViewCell * _Nullable)dequeueReusableCellWithClass:(Class)cellClass forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
