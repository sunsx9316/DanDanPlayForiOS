//
//  DDPPlayerNoticeView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  提示视图 从左边弹出

#import "DDPBlurView.h"

@interface DDPPlayerNoticeView : DDPBlurView

@property (copy, nonatomic) NSString *title;

/**
 自动隐藏时间 默认 3s
 */
@property (assign, nonatomic) float autoDismissTime;

@property (copy, nonatomic) void(^touchTitleCallBack)(void);
@property (copy, nonatomic) void(^touchCloseButtonCallBack)(void);

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *closeButton;

- (void)show;
- (void)dismiss;
@end
