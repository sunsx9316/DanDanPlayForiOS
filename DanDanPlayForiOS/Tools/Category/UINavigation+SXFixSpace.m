//
//  UINavigation+SXFixSpace.m
//  UINavigation-SXFixSpace
//
//  Created by charles on 2017/9/8.
//  Copyright © 2017年 None. All rights reserved.
//

#import "UINavigation+SXFixSpace.h"
//#import "NSObject+SXRuntime.h"
#import <UIKit/UIKit.h>

#ifndef deviceVersion
#define deviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#endif

static BOOL sx_disableFixSpace = NO;

@implementation UIImagePickerController (SXFixSpace)
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceMethod:@selector(viewWillAppear:)
//                                     with:@selector(sx_viewWillAppear:)];
//
//        [self swizzleInstanceMethod:@selector(viewWillDisappear:)
//                                     with:@selector(sx_viewWillDisappear:)];
//    });
//}


- (void)sx_viewWillAppear:(BOOL)animated {
    sx_disableFixSpace = YES;
    [self sx_viewWillAppear:animated];
}

- (void)sx_viewWillDisappear:(BOOL)animated{
    sx_disableFixSpace = NO;
    [self sx_viewWillDisappear:animated];
}

@end

@implementation UINavigationBar (SXFixSpace)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceMethod:@selector(layoutSubviews)
//                                     with:@selector(sx_layoutSubviews)];
//    });
//}

- (void)sx_layoutSubviews{
    [self sx_layoutSubviews];
    
    if (@available(iOS 11.0, *)) {//需要调节
        self.layoutMargins = UIEdgeInsetsZero;
        CGFloat space = 5;
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) containsString:@"ContentView"]) {
                subview.layoutMargins = UIEdgeInsetsMake(0, space, 0, space);//可修正iOS11之后的偏移
                break;
            }
        }
    }
}

@end

@implementation UINavigationItem (SXFixSpace)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceMethod:@selector(setLeftBarButtonItem:)
//                                     with:@selector(sx_setLeftBarButtonItem:)];
//        
////        [self swizzleInstanceMethod:@selector(setLeftBarButtonItems:)
////                                     with:@selector(sx_setLeftBarButtonItems:)];
//        
//        [self swizzleInstanceMethod:@selector(setRightBarButtonItem:)
//                                     with:@selector(sx_setRightBarButtonItem:)];
//        
////        [self swizzleInstanceMethod:@selector(setRightBarButtonItems:)
////                                     with:@selector(sx_setRightBarButtonItems:)];
//    });
//    
//}

- (void)sx_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    if (@available(iOS 11.0, *)) {
        [self sx_setLeftBarButtonItem:leftBarButtonItem];
    }
    else {
        if (!sx_disableFixSpace && leftBarButtonItem) {//存在按钮且需要调节
            [self setLeftBarButtonItems:@[[self fixedSpaceWithWidth:-10], leftBarButtonItem]];
        }
        else {//不存在按钮,或者不需要调节
            [self sx_setLeftBarButtonItem:leftBarButtonItem];
        }
    }
}

- (void)sx_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    if (@available(iOS 11.0, *)) {
        if (leftBarButtonItems.count) {
            NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:sx_defaultFixSpace-20]];//可修正iOS11之前的偏移
            [items addObjectsFromArray:leftBarButtonItems];
            [self sx_setLeftBarButtonItems:items];
        }
        else {
            [self sx_setLeftBarButtonItems:leftBarButtonItems];
        }
    }
    else {
        [self sx_setLeftBarButtonItems:leftBarButtonItems];
    }
}

- (void)sx_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    if (@available(iOS 11.0, *)) {
        [self sx_setRightBarButtonItem:rightBarButtonItem];
    } else {
        if (!sx_disableFixSpace && rightBarButtonItem) {//存在按钮且需要调节
            [self setRightBarButtonItems:@[[self fixedSpaceWithWidth:-10], rightBarButtonItem]];
        } else {//不存在按钮,或者不需要调节
            [self sx_setRightBarButtonItem:rightBarButtonItem];
        }
    }
}

- (void)sx_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    if (@available(iOS 11.0, *)) {
        if (rightBarButtonItems.count) {
            NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:sx_defaultFixSpace-20]];//可修正iOS11之前的偏移
            [items addObjectsFromArray:rightBarButtonItems];
            [self sx_setRightBarButtonItems:items];
        }
        else {
            [self sx_setRightBarButtonItems:rightBarButtonItems];
        }
    }
    else {
        [self sx_setRightBarButtonItems:rightBarButtonItems];
    }
}

- (UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end
