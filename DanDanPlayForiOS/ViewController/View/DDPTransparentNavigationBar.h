//
//  DDPTransparentNavigationBar.h
//  AICoin
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 AICoin. All rights reserved.
//  透明导航栏

#import "DDPBaseNavigationBar.h"

@interface DDPTransparentNavigationBar : DDPBaseNavigationBar

/**
 背景色
 */
@property (nonatomic, strong) UIColor *bgColor;

/**
 背景透明度
 */
@property (nonatomic, assign) CGFloat bgAlpha;


/**
 上界 默认导航栏高
 */
@property (nonatomic, assign) CGFloat upperBound;

/**
 下界 默认200
 */
@property (nonatomic, assign) CGFloat lowerBound;



/**
 根据偏移值更新导航栏透明度
 
 @param offset 偏移值
 */
- (void)updateTransparentWithOffset:(CGPoint)offset;


/**
 根据偏移值更新导航栏透明度 titleView的显示行为会和背景色一样
 
 @param offset 偏移值

 @param titleView titleView
 */
- (void)updateTransparentWithOffset:(CGPoint)offset titleView:(UIView *)titleView;
@end
