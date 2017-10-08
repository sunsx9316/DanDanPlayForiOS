//
//  JHControlView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHControlView : UIView
//@property (copy, nonatomic) void(^rateChangeCallBack)(CGFloat progress);
@property (assign, nonatomic) CGFloat progress;
- (instancetype)initWithImage:(UIImage *)image;
@property (assign, nonatomic, readonly, getter=isShowing) BOOL showing;
@property (assign, nonatomic, getter=isDragging) BOOL dragging;
- (void)showFromView:(UIView *)view;
- (void)dismiss;
- (void)resetTimer;
- (void)dismissAfter:(NSInteger)second;
@end
