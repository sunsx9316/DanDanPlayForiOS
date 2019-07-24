//
//  UIImage+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/3/10.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "UIImage+Tools.h"

@implementation UIImage (Tools)
+ (UIImage *)ddp_placeHolder {
    return [UIImage imageNamed:@"comment_place_holder"];
}

- (instancetype)renderByMainColor {
    let inset = self.capInsets;
    let img = [self imageByTintColor:UIColor.ddp_mainColor];
    if (UIEdgeInsetsEqualToEdgeInsets(inset, UIEdgeInsetsZero)) {
        return img;
    }
    return [img resizableImageWithCapInsets:inset];
}

@end
