//
//  DDPPlayerNoticeView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  提示视图 从左边弹出

#import "DDPBlurView.h"

@class DDPPlayerNoticeView;
@protocol DDPPlayerNoticeViewDelegate <NSObject>
@optional
- (void)playerNoticeViewDidTouchButton;
@end

@interface DDPPlayerNoticeView : DDPBlurView

/**
 自动隐藏时间 默认 3s
 */
@property (assign, nonatomic) float autoDismissTime;
@property (strong, nonatomic) UIButton *titleButton;
@property (strong, nonatomic) UIButton *closeButton;
@property (weak, nonatomic) id<DDPPlayerNoticeViewDelegate>delegate;
- (void)show;
- (void)dismiss;
@end
