//
//  PlayerConfigPanelView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器右边的控制面板

#import "JHBlurView.h"
#define CONFIG_VIEW_WIDTH_RATE 0.5

@class PlayerConfigPanelView;
@protocol PlayerConfigPanelViewDelegate <NSObject>
@optional
- (void)playerConfigPanelView:(PlayerConfigPanelView *)view didSelectedModel:(VideoModel *)model;
- (void)playerConfigPanelView:(PlayerConfigPanelView *)view didTouchStepper:(CGFloat)value;
- (void)playerConfigPanelViewDidTouchSelectedDanmakuCell;
- (void)playerConfigPanelViewDidTouchMatchCell;
@end

@interface PlayerConfigPanelView : JHBlurView
@property (weak, nonatomic) id<PlayerConfigPanelViewDelegate> delegate;
@property (assign, nonatomic, getter=isShow) BOOL show;
- (void)showWithAnimate:(BOOL)flag;
- (void)dismissWithAnimate:(BOOL)flag;
@end
