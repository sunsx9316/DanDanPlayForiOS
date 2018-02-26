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

+ (UIFont *)ddp_blodLargeSizeFont {
    return [UIFont boldSystemFontOfSize:22 + 22 * (ddp_isPad() * 0.5)];
}

+ (UIFont *)ddp_veryBigSizeFont {
    return [UIFont systemFontOfSize:20 + 20 * (ddp_isPad() * 0.5)];
}

+ (UIFont *)ddp_bigSizeFont {
    return [UIFont systemFontOfSize:18 + 18 * (ddp_isPad() * 0.5)];
}

+ (UIFont *)ddp_normalSizeFont {
    return [UIFont systemFontOfSize:16 + 16 * (ddp_isPad() * 0.5)];
}


+ (UIFont *)ddp_smallSizeFont {
    return [UIFont systemFontOfSize:14 + 14 * (ddp_isPad() * 0.5)];
}

+ (UIFont *)ddp_verySmallSizeFont {
    return [UIFont systemFontOfSize:12 + 12 * (ddp_isPad() * 0.5)];
}


@end
