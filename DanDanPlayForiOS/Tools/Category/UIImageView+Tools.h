//
//  UIImageView+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Tools)
- (void)ddp_setImageWithURL:(NSURL *)imageURL;
- (void)ddp_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder;
- (void)ddp_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                  progress:(YYWebImageProgressBlock)progress
                   manager:(YYWebImageManager *)manager
                 transform:(YYWebImageTransformBlock)transform
                completion:(YYWebImageCompletionBlock)completion;
- (void)ddp_setImageWithFadeType:(UIImage *)image;
@end
