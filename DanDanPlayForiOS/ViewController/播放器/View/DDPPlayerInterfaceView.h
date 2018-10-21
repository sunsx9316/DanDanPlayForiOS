//
//  DDPPlayerInterfaceView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放器UI面板

#import <UIKit/UIKit.h>
#import "DDPPlayerConfigPanelViewController.h"

@class DDPPlayerInterfaceView, DDPMediaPlayer;
@protocol DDPPlayerInterfaceViewDelegate <DDPPlayerConfigPanelViewControllerDelegate>

@optional

/**
 点击发送弹幕按钮
 */
- (void)interfaceViewDidTouchSendDanmakuButton;

/**
 点击滑动条

 @param view view
 @param time 时间
 */
- (void)interfaceView:(DDPPlayerInterfaceView *)view touchSliderWithTime:(int)time;

/**
 点击弹幕隐藏按钮

 @param view view
 @param visiable 是否可见
 */
- (void)interfaceView:(DDPPlayerInterfaceView *)view touchDanmakuVisiableButton:(BOOL)visiable;

/**
 点击字幕空视图
 */
- (void)interfaceViewDidTapSubTitleIndexEmptyView;

/**
 点击匹配按钮
 */
- (void)interfaceViewDidTouchCustomMatchButton;
@end

@class DDPBlurView;
@interface DDPPlayerInterfaceView : UIView

@property (weak, nonatomic) id<DDPPlayerInterfaceViewDelegate> delegate;

@property (weak, nonatomic, readonly) DDPMediaPlayer *player;

//- (instancetype)initWithPlayer:(DDPMediaPlayer *)player frame:(CGRect)frame;

+ (instancetype)creatWithPlayer:(DDPMediaPlayer *)player;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

/**
 是否显示
 */
@property (assign, nonatomic, readonly, getter=isShow) BOOL show;


/**
 视频模型
 */
@property (strong, nonatomic) DDPVideoModel *model;


/**
 显示
 */
- (void)showWithAnimate:(BOOL)flag;

/**
 隐藏
 */
- (void)dismissWithAnimate:(BOOL)flag;

/**
 更新UI状态

 @param currentTime 当前时间
 @param totalTime 总时间
 @param progress 进度
 */
- (void)updateCurrentTime:(NSString *)currentTime totalTime:(NSString *)totalTime progress:(CGFloat)progress;

/**
 更新状态

 @param status 播放器状态
 */
//- (void)updateWithPlayerStatus:(DDPMediaPlayerStatus)status;
@end
