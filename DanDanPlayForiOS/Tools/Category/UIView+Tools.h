//
//  UIView+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tools)
- (void)addMotionEffectWithMaxOffset:(CGFloat)offset;
- (void)removeMotionEffect;

/**
 设置竖直方向必须的约束
 */
- (void)setRequiredContentVerticalResistancePriority;

/**
 设置水平方向必须的约束
 */
- (void)setRequiredContentHorizontalResistancePriority;

/**
 加载nib文件

 @return nib文件
 */
+ (UINib *)loadNib;

/**
 加载view

 @return 加载view
 */
+ (instancetype)fromXib;

/**
 点击边缘
 */
@property (assign, nonatomic) UIEdgeInsets ddp_hitTestSlop;

/**
 在一个半透明视图上显示自己

 @param holderView holderView
 @param completion completion
 */
- (void)ddp_showViewWithHolderView:(UIView *)holderView
                        completion:(void(^)(BOOL finished))completion;
- (void)ddp_dismissViewWithCompletion:(void(^)(BOOL finished))completion;
@end
