//
//  UINavigationItem+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBarButtonItem+Tools.h"

@interface UINavigationItem (Tools)
- (void)addLeftItemFixedSpace:(UIBarButtonItem *)item;
- (void)addRightItemFixedSpace:(UIBarButtonItem *)item;
- (void)addRightItemsFixedSpace:(NSArray <UIBarButtonItem *>*)items;
@end
