//
//  UIFont+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Tools)
@property (assign, nonatomic) BOOL isSystemFont;

+ (UIFont *)ddp_normalSizeFont;
+ (UIFont *)ddp_smallSizeFont;
+ (UIFont *)ddp_verySmallSizeFont;
+ (UIFont *)ddp_bigSizeFont;
+ (UIFont *)ddp_veryBigSizeFont;
+ (UIFont *)ddp_blodLargeSizeFont;
@end
