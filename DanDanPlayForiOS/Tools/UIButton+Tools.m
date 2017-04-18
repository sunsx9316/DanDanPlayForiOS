//
//  UIButton+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIButton+Tools.h"

@implementation UIButton (Tools)
- (void)jh_setImageWithURL:(nullable NSURL *)imageURL
                  forState:(UIControlState)state {
    [self yy_setImageWithURL:imageURL forState:state options:YY_WEB_IMAGE_DEFAULT_OPTION];
}
@end
