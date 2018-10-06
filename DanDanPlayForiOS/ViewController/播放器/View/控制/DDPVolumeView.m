//
//  DDPVolumeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPVolumeView.h"

@interface DDPVolumeView ()
@property (strong, nonatomic, readonly) UISlider *volumeSlider;
@end

@implementation DDPVolumeView
{
    UISlider *_slider;
}

- (void)setDdp_volume:(CGFloat)ddp_volume {
    self.volumeSlider.value = ddp_volume;
}

- (CGFloat)ddp_volume {
    return self.volumeSlider.value;
}

#pragma mark - 懒加载

- (UISlider *)volumeSlider {
    if (_slider == nil) {
        for (UIView *view in [self subviews]) {
            if ([view isMemberOfClass:NSClassFromString(@"MPVolumeSlider")]) {
                _slider = (UISlider *)view;
                break;
            }
        }
    }
    return _slider;
}

@end
