//
//  DDPPlayerControlView.h
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDPPlayerSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPPlayerControlView : NSView
@property (unsafe_unretained) IBOutlet NSButton *playButton;
@property (unsafe_unretained) IBOutlet DDPPlayerSlider *progressSlider;
@property (unsafe_unretained) IBOutlet NSTextField *inputTextField;
@property (unsafe_unretained) IBOutlet NSTextField *timeLabel;
@property (unsafe_unretained) IBOutlet NSButton *volumeButton;
@property (unsafe_unretained) IBOutlet NSButton *danmakuButton;

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

@property (copy, nonatomic) void(^sliderDidChangeCallBack)(CGFloat progress);
@property (copy, nonatomic) void(^buttonDidClickCallBack)(BOOL selected);

@end

NS_ASSUME_NONNULL_END
