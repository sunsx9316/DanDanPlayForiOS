//
//  UINavigationItem+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UINavigationItem+Tools.h"
#import "JHEdgeButton.h"

@implementation UINavigationItem (Tools)
- (void)addLeftItemFixedSpace:(UIBarButtonItem *)item {
    if (item == nil) return;
    self.leftBarButtonItem = item;
}

- (void)addRightItemFixedSpace:(UIBarButtonItem *)item {
    if (item == nil) return;

    self.rightBarButtonItem = item;
}

- (void)addRightItemsFixedSpace:(NSArray <UIBarButtonItem *>*)items {
    if (items.count == 0) return;

    self.rightBarButtonItems = items;
}

@end
