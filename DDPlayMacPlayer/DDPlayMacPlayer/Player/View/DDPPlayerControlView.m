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
    
    self.progressSlider.continuous = YES;
    [self.progressSlider addTarget:self action:@selector(onSliderChange:)];
    [self.playButton addTarget:self action:@selector(onButtonDidClick:)];
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
        case NSLeftMouseDown:
        case NSLeftMouseDragged: {
            _isTracking = YES;
            [self updateLabelWithCurrentTime:_totalTime * sender.doubleValue totalTime:_totalTime];
        }
            break;
        case NSLeftMouseUp: {
            _isTracking = NO;
            if (self.sliderDidChangeCallBack) {
                self.sliderDidChangeCallBack(sender.doubleValue);
            }
        }
            break;
        default: {
            _isTracking = NO;            
        }
            break;
    }
}

- (void)onButtonDidClick:(NSButton *)button {
    if (self.buttonDidClickCallBack) {
        self.buttonDidClickCallBack(button.state == NSControlStateValueOn);
    }
}

@end
