//
//  DownloadStatusView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DownloadStatusView.h"
#import "DownloadViewController.h"

#define PROGRESS_VIEW_SIZE 55.0

@interface DownloadStatusView ()<CacheManagerDelagate>

@property (strong, nonatomic) UIImageView *bgImgView;

@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) CALayer *progressMask;

@property (strong, nonatomic) UILabel *progressBgLabel;
@property (strong, nonatomic) UILabel *progressLabel;

@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DownloadStatusView
{
    CGPoint _pointInDownloadView;
    BOOL _isMove;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _show = NO;
        
        [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.progressBgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)show {
    //已经显示或者没有下载任务则隐藏视图
    if (_show) return;
    
    if (self.superview == nil) {
        [[UIApplication sharedApplication].delegate.window addSubview:self];
    }
    
    self.size = CGSizeMake(PROGRESS_VIEW_SIZE, PROGRESS_VIEW_SIZE);
    self.right = self.superview.right - 10;
    self.bottom = self.superview.bottom - 70;
    
    [self showAnimate];
    
    [self.timer fireDate];
    
    _show = YES;
}

- (void)dismiss {
    if (_show == NO) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.timer invalidate];
        [self removeFromSuperview];
    }];
    
    _show = NO;
}

- (void)showAnimate {
    self.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

#pragma mark - CacheManagerDelagate
- (void)SMBDownloadTasksDidDownloadCompletion {
    [self dismiss];
}

#pragma mark - 私有方法
- (void)timerStart:(NSTimer *)timer {
    NSUInteger _totoalExpectedToReceive = [CacheManager shareCacheManager].totoalExpectedToReceive;
    NSUInteger _totalReceived = [CacheManager shareCacheManager].totoalToReceive;
    
    float progress = _totalReceived * 1.0 / _totoalExpectedToReceive;
    if (isnormal(progress) == NO) {
        progress = 0;
    }
    
    [self updateProgressWithProgress:progress];
}

- (void)updateProgressWithProgress:(float)progress {
    NSString *progressStr = [NSString stringWithFormat:@"%.1f%%", progress * 100];
    self.progressLabel.text = progressStr;
    self.progressBgLabel.text = progressStr;
    self.progressMask.frame = CGRectMake(0, PROGRESS_VIEW_SIZE - PROGRESS_VIEW_SIZE * progress, PROGRESS_VIEW_SIZE, PROGRESS_VIEW_SIZE * progress);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isMove = YES;
    CGPoint pointInWindows = [touches.anyObject locationInView:nil];
    CGSize size = self.size;
    pointInWindows.x -= _pointInDownloadView.x;
    pointInWindows.y -= _pointInDownloadView.y;
    
    //越界处理
    if (pointInWindows.x < 0) {
        pointInWindows.x = 0;
    }
    else if (pointInWindows.x + self.width > kScreenWidth) {
        pointInWindows.x = kScreenWidth - size.width;
    }
    
    if (pointInWindows.y < 0) {
        pointInWindows.y = 0;
    }
    else if (pointInWindows.y + self.height > kScreenHeight) {
        pointInWindows.y = kScreenHeight - size.height;
    }


    self.origin = pointInWindows;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //记录点击的位置
    _pointInDownloadView = [touches.anyObject locationInView:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isMove) {
        _isMove = NO;
    }
    else {
        UITabBarController *tvc = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        UINavigationController *nav = tvc.selectedViewController;
        if ([nav.topViewController isKindOfClass:[DownloadViewController class]] == NO) {
            DownloadViewController *vc = [[DownloadViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - 懒加载

- (UIImageView *)bgImgView {
    if (_bgImgView == nil) {
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_load_hud"]];
        [self addSubview:_bgImgView];
    }
    return _bgImgView;
}

- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.layer.mask = self.progressMask;

        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_load_hud_progress"]];
        
        [_progressView addSubview:imgView];
        [_progressView addSubview:self.progressLabel];
        
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UILabel *)progressLabel {
    if (_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = SMALL_SIZE_FONT;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.text = @"0.0%";
    }
    return _progressLabel;
}

- (UILabel *)progressBgLabel {
    if (_progressBgLabel == nil) {
        _progressBgLabel = [[UILabel alloc] init];
        _progressBgLabel.font = SMALL_SIZE_FONT;
        _progressBgLabel.textColor = [UIColor blackColor];
        _progressBgLabel.textAlignment = NSTextAlignmentCenter;
        _progressBgLabel.text = @"0.0%";
        [self addSubview:_progressBgLabel];
    }
    return _progressBgLabel;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (CALayer *)progressMask {
    if (_progressMask == nil) {
        _progressMask = [CALayer layer];
        _progressMask.backgroundColor = [UIColor blackColor].CGColor;
        _progressMask.frame = CGRectMake(0, PROGRESS_VIEW_SIZE, PROGRESS_VIEW_SIZE, 0);
    }
    return _progressMask;
}

@end
