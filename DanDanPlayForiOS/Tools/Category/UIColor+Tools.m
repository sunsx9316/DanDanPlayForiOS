//
//  UIColor+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIColor+Tools.h"

@implementation UIColor (Tools)

+ (UIColor *)ddp_mainColor {
    return DDPRGBColor(51, 151, 252);
}

+ (UIColor *)ddp_backgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)ddp_veryLightGrayColor {
    return DDPRGBColor(240, 240, 240);
    
}
+ (UIColor *)ddp_lightGrayColor {
    return DDPRGBColor(230, 230, 230);
}

@end
