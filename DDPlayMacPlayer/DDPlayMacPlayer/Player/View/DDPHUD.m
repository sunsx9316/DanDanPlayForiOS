//
//  DDPHUD.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/9/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPHUD.h"
#import <Masonry/Masonry.h>

@interface DDPHUD ()
@property (weak) IBOutlet NSTextField *label;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL showing;
@end

@implementation DDPHUD

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupInit];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupInit];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.stringValue = title;
}

- (void)showAtView:(NSView *)view {
    [self showAtView:view position:DDPHUDPositionTopRight];
}

- (void)showAtView:(NSView *)view position:(DDPHUDPosition)position {
    [self startTimer];
    
    if (_showing == NO) {
        self.alphaValue = 0;
        [view addSubview:self];
        
        switch (position) {
            case DDPHUDPositionTopRight: {
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.trailing.mas_equalTo(-10);
                    make.top.mas_equalTo(10);
                }];
            }
                break;
            case DDPHUDPositionCenter: {
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.mas_equalTo(view);
                }];
            }
                break;
            default:
                break;
        }
        
        _showing = YES;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.2;
            self.animator.alphaValue = 1;
        } completionHandler:^{
            
        }];
    }
    
}

- (void)dismiss {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.2;
        self.animator.alphaValue = 0;
    } completionHandler:^{
        [self removeFromSuperview];
        self.showing = NO;
    }];
}

#pragma mark - Private
- (void)setupInit {
    self.wantsLayer = YES;
    self.layer.cornerRadius = 8;
    self.layer.allowsGroupOpacity = YES;
}

- (void)startTimer {
    @weakify(self)
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        [self dismiss];
    }];
}

@end
