//
//  DDPPlayViewController.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayViewController.h"
#import <Masonry/Masonry.h>
#import <JHDanmakuRender/JHDanmakuRender.h>
#import "DDPPlayerControlView.h"
#import "NSView+DDPTools.h"
#import "DDPMediaPlayer.h"
#import "DDPSessionManager.h"

@interface DDPPlayViewController ()<DDPMediaPlayerDelegate, DDPSessionManagerObserver, JHDanmakuEngineDelegate>
@property (strong, nonatomic) DDPPlayerControlView *controlView;
@property (strong, nonatomic) JHDanmakuEngine *danmakuEngine;
@property (strong, nonatomic) DDPMediaPlayer *player;
@end

@implementation DDPPlayViewController

- (DDPPlayerControlView *)controlView {
    if (_controlView == nil) {
        _controlView = [DDPPlayerControlView loadFromNib];
        @weakify(self)
        _controlView.sliderDidChangeCallBack = ^(CGFloat progress) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.player setPosition:progress completionHandler:nil];
        };
        
        _controlView.buttonDidClickCallBack = ^(BOOL selected) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            if (selected) {
                [self.player play];
            } else {
                [self.player pause];
            }
        };
        
    }
    return _controlView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.wantsLayer = YES;
    self.player.mediaView.wantsLayer = NO;
    [self.view addSubview:self.player.mediaView];
    [self.view addSubview:self.danmakuEngine.canvas];
    [self.view addSubview:self.controlView];
    
    [self.player.mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(0);
    }];
    
    [self.danmakuEngine.canvas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.player.mediaView);
    }];
    
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(self.player.mediaView.mas_bottom);
    }];
    
    [[DDPSessionManager sharedManager] addObserver:self];
}

- (void)dealloc {
    [[DDPSessionManager sharedManager] removeObserver:self];
}

#pragma mark - DDPMediaPlayerDelegate
- (void)mediaPlayer:(DDPMediaPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    [self.controlView updateCurrentTime:currentTime totalTime:totalTime];
}

- (void)mediaPlayer:(DDPMediaPlayer *)player statusChange:(DDPMediaPlayerStatus)status {
    
    switch (status) {
        case DDPMediaPlayerStatusPlaying:
        {
            [self.danmakuEngine start];
            self.controlView.playButton.state = NSControlStateValueOn;
        }
            break;
        case DDPMediaPlayerStatusNextEpisode:
            break;
        default:
            [self.danmakuEngine pause];
            self.controlView.playButton.state = NSControlStateValueOff;
            break;
    }
}

- (void)mediaPlayer:(DDPMediaPlayer *)player rateChange:(float)rate {
    self.danmakuEngine.systemSpeed = rate;
}

- (void)mediaPlayer:(DDPMediaPlayer *)player userJumpWithTime:(NSTimeInterval)time {
    [self.danmakuEngine setCurrentTime:time];
    if (player.isPlaying == NO) {
        [self.danmakuEngine pause];
    }
}

#pragma mark - DDPDanmakuEngineDelegate
//- (NSArray <__kindof JHBaseDanmaku*>*)danmakuEngine:(JHDanmakuEngine *)danmakuEngine didSendDanmakuAtTime:(NSUInteger)time {
//    if (_currentTime == time) return nil;
//
//    _currentTime = time;
//
//    //远端弹幕
//    let tempDanmakus = [self.danmakuProducer damakusAtTime:_currentTime];
//
//    //已发送的弹幕
//    let sentDanmakus = self.sentDanmakuDic[@(_currentTime)];
//    if (sentDanmakus) {
//        return [sentDanmakus arrayByAddingObjectsFromArray:tempDanmakus];
//    }
//    return tempDanmakus;
//}
//
//- (BOOL)danmakuEngine:(JHDanmakuEngine *)danmakuEngine shouldSendDanmaku:(__kindof JHBaseDanmaku *)danmaku {
//
//    //自己发的忽略屏蔽规则
//    if (danmaku.sendByUserId != 0) {
//        return YES;
//    }
//
//    DDPDanmakuShieldType danmakuShieldType = [DDPCacheManager shareCacheManager].danmakuShieldType;
//    //屏蔽滚动弹幕
//    if ((danmakuShieldType & DDPDanmakuShieldTypeScrollToLeft) && [danmaku isKindOfClass:[JHScrollDanmaku class]]) {
//        return false;
//    }
//
//    if ([danmaku isKindOfClass:[JHFloatDanmaku class]]) {
//        JHFloatDanmaku *_danmaku = (JHFloatDanmaku *)danmaku;
//
//        if (danmakuShieldType & DDPDanmakuShieldTypeFloatAtTo && _danmaku.position == JHFloatDanmakuPositionAtTop) {
//            return false;
//        }
//
//        if (danmakuShieldType & DDPDanmakuShieldTypeFloatAtBottom && _danmaku.position == JHFloatDanmakuPositionAtBottom) {
//            return false;
//        }
//    }
//
//    //屏蔽彩色弹幕
//    if (danmakuShieldType & DDPDanmakuShieldTypeColor) {
//        UIColor *color = danmaku.textColor;
//
//        if ([color isEqual:[UIColor whiteColor]] || [color isEqual:[UIColor blackColor]]) {
//            return true;
//        }
//        return false;
//    }
//
//    return !danmaku.filter;
//}

#pragma mark - DDPSessionManagerObserver
- (void)dispatchManager:(DDPSessionManager *)manager didReceiveMessage:(DDPMessageModel *)message {
    if ([message.name isEqualToString:@"player"]) {
        NSDictionary *parameter = message.parameter;
        [self.player setMediaURL:[NSURL fileURLWithPath:parameter[@"path"]]];
        [self.player play];
    }
}

#pragma mark - Lazy load
- (JHDanmakuEngine *)danmakuEngine {
    if (_danmakuEngine == nil) {
        _danmakuEngine = [[JHDanmakuEngine alloc] init];
        _danmakuEngine.delegate = self;
//        [_danmakuEngine setSpeed:[DDPCacheManager shareCacheManager].danmakuSpeed];
//        _danmakuEngine.canvas.alpha = [DDPCacheManager shareCacheManager].danmakuOpacity;
//        _danmakuEngine.limitCount = [DDPCacheManager shareCacheManager].danmakuLimitCount;
    }
    return _danmakuEngine;
}

- (DDPMediaPlayer *)player {
    if (_player == nil) {
        _player = [[DDPMediaPlayer alloc] init];
        _player.delegate = self;
    }
    return _player;
}

@end
