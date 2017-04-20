//
//  UIImageView+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIImageView+Tools.h"

@implementation UIImageView (Tools)
- (void)jh_setImageWithURL:(NSURL *)imageURL {
    [self yy_setImageWithURL:imageURL options:YY_WEB_IMAGE_DEFAULT_OPTION];
}

- (void)jh_setImageWithFadeType:(UIImage *)image {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:@"JHImageFadeAnimationKey"];
    self.image = image;
}

@end
