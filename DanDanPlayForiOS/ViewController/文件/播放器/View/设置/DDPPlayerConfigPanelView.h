//
//  DDPPlayerConfigPanelView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器右边的控制面板

#import "DDPBlurView.h"
#define CONFIG_VIEW_WIDTH_RATE 0.5

@class DDPPlayerConfigPanelView;
@protocol DDPPlayerConfigPanelViewDelegate <NSObject>
@optional
- (void)playerConfigPanelView:(DDPPlayerConfigPanelView *)view didSelectedModel:(DDPVideoModel *)model;
- (void)playerConfigPanelView:(DDPPlayerConfigPanelView *)view didTouchStepper:(CGFloat)value;
- (void)playerConfigPanelViewDidTouchSelectedDanmakuCell;
- (void)playerConfigPanelViewDidTouchMatchCell;
- (void)playerConfigPanelViewDidTouchFilterCell;
@end

@interface DDPPlayerConfigPanelView : DDPBlurView
@property (weak, nonatomic) id<DDPPlayerConfigPanelViewDelegate> delegate;
@property (assign, nonatomic, getter=isShow) BOOL show;
- (void)showWithAnimate:(BOOL)flag;
- (void)dismissWithAnimate:(BOOL)flag;
@end
