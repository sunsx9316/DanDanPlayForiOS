//
//  PlayerConfigPanelView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器控制面板

#import "JHBlurView.h"

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
@property (assign, nonatomic) BOOL show;
@end
