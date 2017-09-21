//
//  UIImageView+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Tools)
- (void)jh_setImageWithURL:(NSURL *)imageURL;
- (void)jh_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder;
- (void)jh_setImageWithFadeType:(UIImage *)image;
@end
