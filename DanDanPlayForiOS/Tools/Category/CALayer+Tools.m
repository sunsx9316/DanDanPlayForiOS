//
//  CALayer+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "CALayer+Tools.h"

@implementation CALayer (Tools)
- (void)jh_setImageWithURL:(NSURL *)imageURL {
    [self yy_setImageWithURL:imageURL placeholder:[UIImage imageNamed:@"comment_place_holder"] options:YY_WEB_IMAGE_DEFAULT_OPTION completion:nil];
}

- (void)jh_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self yy_setImageWithURL:imageURL placeholder:placeholder options:YY_WEB_IMAGE_DEFAULT_OPTION completion:nil];
}

@end
