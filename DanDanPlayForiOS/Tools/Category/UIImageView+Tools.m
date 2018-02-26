//
//  UIImageView+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIImageView+Tools.h"

@implementation UIImageView (Tools)
- (void)ddp_setImageWithURL:(NSURL *)imageURL {
    [self ddp_setImageWithURL:imageURL placeholder:[UIImage imageNamed:@"comment_place_holder"] progress:nil manager:nil transform:nil completion:nil];
}

- (void)ddp_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self ddp_setImageWithURL:imageURL placeholder:placeholder progress:nil manager:nil transform:nil completion:nil];
}

- (void)ddp_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                  progress:(YYWebImageProgressBlock)progress
                   manager:(YYWebImageManager *)manager
                 transform:(YYWebImageTransformBlock)transform
                completion:(YYWebImageCompletionBlock)completion {
    [self yy_setImageWithURL:imageURL placeholder:placeholder options:YY_WEB_IMAGE_DEFAULT_OPTION progress:progress transform:transform completion:completion];
}

- (void)ddp_setImageWithFadeType:(UIImage *)image {
    self.image = nil;
    [self.layer removeAllAnimations];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:@"JHImageFadeAnimationKey"];
    self.image = image;
}

@end
