//
//  UIViewController+FullScreenPopGesture.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 AICoin. All rights reserved.
//
#import <UIKit/UIKit.h>

@class DDPBaseNavigationController;
@interface UIViewController (FullScreenPopGesture)

/**
 是否启用全屏手势 默认 true 为false相当于设置响应滑动事件的左边距为40
 */
@property (nonatomic, assign) BOOL ddp_fullScreenPopGestureEnabled;

/**
 是否隐藏导航栏
 */
@property (nonatomic, assign) BOOL ddp_navigationBarHidden;

/**
 最顶部的导航控制器
 */
@property (nonatomic, strong, readonly) DDPBaseNavigationController *ddp_navigationController;


/**
 响应滑动事件的左边距
 */
@property (nonatomic, assign) CGFloat ddp_interactivePopMaxAllowedInitialDistanceToLeftEdge;
@end
