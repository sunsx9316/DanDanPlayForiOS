//
//  DDPControlView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPControlView.h"

@interface DDPControlView ()
@property (strong, nonatomic) UIView *bgView;
//@property (strong, nonatomic) UIVisualEffectView *progressVibrancyView;
//@property (strong, nonatomic) UIVisualEffectView *iconVibrancyView;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DDPControlView
{
    BOOL _isShowing;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithFrame:CGRectZero]) {
        self.iconImgView.image = [image yy_imageByTintColor:[UIColor blackColor]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isShowing = NO;
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];

        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(0);
            make.bottom.mas_offset(-10);
            make.centerX.mas_equalTo(0);
        }];
        
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progress = _progress;
}

- (void)setProgress:(CGFloat)progress {
    _progress = MAX(MIN(progress, 1), 0);
    
    var frame = self.bounds;
    frame.origin.y = frame.size.height * (1 - _progress);
    self.progressView.frame = frame;
}

- (void)showFromView:(UIView *)view {
    if (_isShowing == YES) return;
    _isShowing = YES;
    
    if (view == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    else {
        [view addSubview:self];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(120);
    }];
    
    [self.layer removeAllAnimations];
    self.alpha = 1;
    
}

- (void)dismiss {
    if (_isShowing == NO) return;
    _isShowing = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (_isShowing) return;
        
        self.timer.fireDate = [NSDate distantFuture];
        [self removeFromSuperview];
        if (self.dismissCallBack) {
            self.dismissCallBack(finished);
        }
    }];
}


- (void)dismissAfter:(NSInteger)second {
    if (_isShowing == NO) return;
    
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:second];
}

- (void)resetTimer {
    self.timer.fireDate = [NSDate distantFuture];
}

- (BOOL)isShowing {
    return _isShowing;
}

#pragma mark - 懒加载
- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = DDPRGBAColor(0, 0, 0, 0.8);
        
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        [self addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(dismiss) userInfo:nil repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
