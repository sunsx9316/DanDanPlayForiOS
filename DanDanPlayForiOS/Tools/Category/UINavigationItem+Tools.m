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
    
//    if (@available(iOS 11.0, *)) {
//        UIButton *button = item.customView;
//
//        if ([button isKindOfClass:[UIControl class]]) {
//            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        }
        self.leftBarButtonItem = item;
//    }
//    else {
//        UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        fixItem.width = -10;
//        self.leftBarButtonItems = @[fixItem, item];
//    }
}

- (void)addRightItemFixedSpace:(UIBarButtonItem *)item {
    if (item == nil) return;
    
//    if (@available(iOS 11.0, *)) {
//        UIButton *button = item.customView;
//        if ([button isKindOfClass:[UIControl class]]) {
//            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//        }
        self.rightBarButtonItem = item;
//    }
//    else {
//        UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        fixItem.width = -10;
//        self.rightBarButtonItems = @[fixItem, item];
//    }
}

- (void)addRightItemsFixedSpace:(NSArray <UIBarButtonItem *>*)items {
    if (items.count == 0) return;
    
//    if (@available(iOS 11.0, *)) {
//        [items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            UIButton *button = obj.customView;
//            if ([button isKindOfClass:[UIControl class]]) {
//                [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//            }
//        }];
//        self.rightBarButtonItems = items;
//    }
//    else {
//        UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        fixItem.width = -10;
//
//        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:items];
//        [tempArr insertObject:fixItem atIndex:0];
        self.rightBarButtonItems = items;
//    }
}

@end
