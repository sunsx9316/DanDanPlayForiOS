//
//  PlayerNoticeView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  提示视图 从左边弹出

#import "JHBlurView.h"

@class PlayerNoticeView;
@protocol PlayerNoticeViewDelegate <NSObject>
@optional
- (void)playerNoticeViewDidTouchButton;
@end

@interface PlayerNoticeView : JHBlurView
@property (strong, nonatomic) UIButton *titleButton;
@property (weak, nonatomic) id<PlayerNoticeViewDelegate>delegate;
- (void)show;
- (void)dismiss;
@end
