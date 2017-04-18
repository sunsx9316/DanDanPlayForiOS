//
//  UIImageView+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIImageView+Tools.h"

@implementation UIImageView (Tools)
- (void)jh_setImageWithURL:(nullable NSURL *)imageURL {
    [self yy_setImageWithURL:imageURL options:YY_WEB_IMAGE_DEFAULT_OPTION];
}
@end
