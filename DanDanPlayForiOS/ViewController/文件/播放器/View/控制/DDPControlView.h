//
//  DDPControlView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPControlView : UIView
@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic, readonly, getter=isShowing) BOOL showing;
@property (copy, nonatomic) void(^dismissCallBack)(BOOL finish);

- (instancetype)initWithImage:(UIImage *)image;
- (void)showFromView:(UIView *)view;
- (void)dismiss;
- (void)dismissAfter:(NSInteger)second;
- (void)resetTimer;
@end
