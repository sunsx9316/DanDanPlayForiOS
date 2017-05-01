//
//  UIFont+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIFont+Tools.h"

static NSString *const isSystemFontKey = @"is_system_font";

@implementation UIFont (Tools)

- (void)setIsSystemFont:(BOOL)isSystemFont {
    objc_setAssociatedObject(self, &isSystemFontKey, @(isSystemFont), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSystemFont {
    return [objc_getAssociatedObject(self, &isSystemFontKey) boolValue];
}

@end
