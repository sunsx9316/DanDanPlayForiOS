//
//  HYSwitch.h
//  Test
//
//  Created by Shadow on 14-5-17.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_ON_COLOR [UIColor colorWithRed:76/255.f green:216/255.f blue:100/255.f alpha:1]

typedef void(^SwitchChangedAction)(BOOL isOn);

@interface HYSwitch : UIView

/**
 开关状态发生变化后的回调block.
 */
@property (nonatomic, strong) SwitchChangedAction action;

/**
 开关开启后的背景色, 默认为DEFAULT_ON_COLOR.
 */
@property (nonatomic, strong) UIColor *onColor;

/**
 开关关闭后的背景色, 默认为[UIColor lightGrayColor].
 */
@property (nonatomic, strong) UIColor *offColor;

/**
 圆形按钮的颜色, 默认为[UIColor whiteColor].
 */
@property (nonatomic, strong) UIColor *buttonColor;

@property (strong, nonatomic) UIColor *onTextColor;

@property (strong, nonatomic) UIColor *offTextColor;

@property (copy, nonatomic) NSString *onText;

@property (copy, nonatomic) NSString *offText;

/**
 开关状态, 默认为NO.
 */
@property (nonatomic, getter = isOn, readonly) BOOL on;

/**
 代码设置开关状态请使用该方法.
 action参数表示是否在切换状态后触发回调block.
 */
- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated doAction:(BOOL)action;

/**
 使用该方法实例化对象, 比例不要太奇葩就行.
 */
- (id)initWithFrame:(CGRect)frame;

@end
