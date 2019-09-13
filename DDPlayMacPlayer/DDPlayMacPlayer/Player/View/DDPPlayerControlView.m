//
//  DDPPlayerControlView.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayerControlView.h"
#import "DDPMediaPlayer.h"

@implementation DDPPlayerControlView
{
    BOOL _isTracking;
    NSTimeInterval _currentTime;
    NSTimeInterval _totalTime;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.8].CGColor;
    
    self.progressSlider.continuous = YES;
    [self.progressSlider addTarget:self action:@selector(onSliderChange:)];
    [self.playButton addTarget:self action:@selector(onPlayButtonDidClick:)];
    [self.danmakuButton addTarget:self action:@selector(onDanmakuButtonDidClick:)];
    @weakify(self)
    self.inputTextField.keyUpCallBack = ^(NSEvent * _Nonnull event) {
        @strongify(self)
        if (!self.sendDanmakuCallBack) {
            return;
        }
        
        if ([event.charactersIgnoringModifiers isEqualToString:@"\r"]) {
            self.sendDanmakuCallBack(self.inputTextField.stringValue);
            self.inputTextField.stringValue = @"";
        }
    };
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (_isTracking) {
        return;
    }
    
    //更新当前时间
    [self updateLabelWithCurrentTime:currentTime totalTime:totalTime];
    CGFloat progress = totalTime == 0 ? 0 : currentTime / totalTime;
    self.progressSlider.doubleValue = progress;
}

#pragma mark - 私有方法
- (void)updateLabelWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    _currentTime = currentTime;
    _totalTime = totalTime;
    
    let currentTimeStr = ddp_mediaFormatterTime(_currentTime);
    let totalTimeStr = ddp_mediaFormatterTime(_totalTime);
    
    //更新当前时间
    self.timeLabel.stringValue = [NSString stringWithFormat:@"%@/%@", currentTimeStr, totalTimeStr];
}

- (void)onSliderChange:(DDPPlayerSlider *)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    switch (event.type) {
        case NSEventTypeLeftMouseDown:
        case NSEventTypeLeftMouseDragged: {
            _isTracking = YES;
            [self updateLabelWithCurrentTime:_totalTime * sender.doubleValue totalTime:_totalTime];
        }
            break;
        case NSEventTypeLeftMouseUp: {
            _isTracking = NO;
            if (self.sliderDidChangeCallBack) {
                self.sliderDidChangeCallBack(sender.doubleValue);
            }
        }
            break;
        default:
//        {
//            _isTracking = NO;            
//        }
            break;
    }
}

- (void)onPlayButtonDidClick:(NSButton *)button {
    if (self.playButtonDidClickCallBack) {
        self.playButtonDidClickCallBack(button.state == NSControlStateValueOn);
    }
}

- (void)onDanmakuButtonDidClick:(NSButton *)button {
    if (self.danmakuButtonDidClickCallBack) {
        self.danmakuButtonDidClickCallBack(button.state == NSControlStateValueOn);
    }
}

@end
