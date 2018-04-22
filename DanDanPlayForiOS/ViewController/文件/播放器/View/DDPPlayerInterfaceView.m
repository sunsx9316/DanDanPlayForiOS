//
//  DDPPlayerInterfaceView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerInterfaceView.h"
#import "DDPPlayerInterfaceHolderView.h"
#import "DDPVolumeView.h"
#import "DDPBlurView.h"
#import "DDPEdgeButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <YYKeyboardManager.h>
#import "DDPVideoModel+Tools.h"
#import <AVFoundation/AVFoundation.h>

#import "DDPMatchViewController.h"

#define AUTO_DISS_MISS_TIME 3.5f

#define HUD_TAG 10086

static const float slowRate = 0.02f;
static const float normalRate = 0.1f;
static const float fastRate = 0.6f;

typedef NS_ENUM(NSUInteger, InterfaceViewPanType) {
    InterfaceViewPanTypeInactive,
    InterfaceViewPanTypeProgress,
    InterfaceViewPanTypeVolume,
    InterfaceViewPanTypeLight,
};

@interface DDPPlayerInterfaceView ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UISlider *progressSlider;

@property (strong, nonatomic) UISwitch *danmakuHideSwitch;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *subTitleIndexButton;
@property (strong, nonatomic) UIButton *screenShotButton;
@property (strong, nonatomic) UIActivityIndicatorView *screenShotIndicatorView;

/**
 设置按钮
 */
@property (strong, nonatomic) DDPEdgeButton *settingButton;

/**
 发弹幕按钮
 */
@property (strong, nonatomic) UIButton *sendDanmakuButton;

/**
 手势视图
 */
@property (strong, nonatomic) UIView *gestureView;
//从右边画出来的控制面板
@property (strong, nonatomic) DDPPlayerConfigPanelView *configPanelView;
//字幕视图
@property (strong, nonatomic) DDPPlayerSubTitleIndexView *subTitleIndexView;
//左边弹出来的匹配视图
@property (strong, nonatomic) DDPPlayerMatchView *matchNoticeView;
//上次播放时间
@property (strong, nonatomic) DDPPlayerNoticeView *lastTimeNoticeView;
//音量控制视图
@property (strong, nonatomic) DDPControlView *volumeControlView;
//亮度控制视图
@property (strong, nonatomic) DDPControlView *brightnessControlView;


@property (strong, nonatomic) DDPPlayerInterfaceHolderView *holdView;

@property (strong, nonatomic) DDPVolumeView *mpVolumeView;


@property (strong, nonatomic) NSTimer *timer;
//上次滑动时间
@property (strong, nonatomic) NSDate *lastPanDate;

@property (weak, nonatomic) DDPMediaPlayer *player;
@end

@implementation DDPPlayerInterfaceView
{
    //进度条是否不响应通知
    BOOL _isSliderNoActionNotice;
    //滑动速率
    float _sliderRate;
    //手势类型
    InterfaceViewPanType _panType;
    //记录滑动手势刚开始点击的位置
    CGPoint _panGestureTouchPoint;
}

- (instancetype)initWithPlayer:(DDPMediaPlayer *)player frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _show = YES;
        _panGestureTouchPoint = CGPointZero;
        //加入最底层
        [self addSubview:self.mpVolumeView];
        
        self.player = player;
        
        [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.holdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.configPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(self.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
            make.left.equalTo(self.mas_right);
        }];
        
        [self.matchNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_offset(-25);
        }];
        
        [self.lastTimeNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.equalTo(self.matchNoticeView.mas_bottom).mas_offset(15);
        }];
        
        //监听音量变化
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:YES error:nil];
        [audioSession addObserver:self forKeyPath:DDP_KEYPATH(audioSession, outputVolume) options:NSKeyValueObservingOptionNew context:nil];
        
        @weakify(self)
        self.timer = [NSTimer timerWithTimeInterval:AUTO_DISS_MISS_TIME block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self dismissWithAnimate:YES];
            timer.fireDate = [NSDate distantFuture];
        } repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self resetTimer];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //物理按键调节音量
    if ([keyPath isEqualToString:DDP_KEYPATH([AVAudioSession sharedInstance], outputVolume)]) {
        
        if (self->_lastPanDate != nil) return;
        
        CGFloat volume = [change[NSKeyValueChangeNewKey] floatValue];
        
        if (self.volumeControlView.isShowing == NO) {
            [self.volumeControlView showFromView:self];
        }
        
        [self.volumeControlView dismissAfter:1];
        self.volumeControlView.progress = volume;
    }
}

- (void)dealloc {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession removeObserver:self forKeyPath:DDP_KEYPATH(audioSession, outputVolume)];
}

- (void)setDelegate:(id<DDPPlayerInterfaceViewDelegate>)delegate {
    _delegate = delegate;
    
    self.configPanelView.delegate = _delegate;
}

- (void)showWithAnimate:(BOOL)flag {
    if (_show == NO) {
        _show = YES;
        self.topView.transform = CGAffineTransformMakeTranslation(0, -30);
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, 30);
        
        dispatch_block_t action = ^{
            self.holdView.alpha = 1;
            self.topView.transform = CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
            [self.viewController setNeedsStatusBarAppearanceUpdate];
            if (@available(iOS 11.0, *)) {
                [self.viewController setNeedsUpdateOfHomeIndicatorAutoHidden];
            }
        };
        
        if (flag) {
            [self animate:action completion:nil];
        }
        else {
            action();
        }
    }
}

- (void)dismissWithAnimate:(BOOL)flag {
    if (_show) {
        _show = NO;
        [self endEditing:YES];
        [self.configPanelView dismissWithAnimate:NO];
        
        dispatch_block_t action = ^{
            self.holdView.alpha = 0;
            self.topView.transform = CGAffineTransformMakeTranslation(0, -30);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 30);
            [self.viewController setNeedsStatusBarAppearanceUpdate];
            if (@available(iOS 11.0, *)) {
                [self.viewController setNeedsUpdateOfHomeIndicatorAutoHidden];
            }
            [self layoutIfNeeded];
        };
        
        if (flag) {
            [self animate:action completion:nil];
        }
        else {
            action();
        }
    }
}

- (void)setModel:(DDPVideoModel *)model {
    _model = model;
    
    self.titleLabel.text = _model.name;
    
    {
        //设置匹配名称
        NSString *matchName = _model.matchName;
        //弹幕匹配数量
        NSString *danmakuCountStr = [NSString stringWithFormat:@"共%ld条弹幕", _model.danmakus.collection.count];
        
        if (matchName.length) {
            [self.matchNoticeView.titleButton setTitle:[matchName stringByAppendingFormat:@"\n%@", danmakuCountStr] forState:UIControlStateNormal];
        }
        else {
            [self.matchNoticeView.titleButton setTitle:danmakuCountStr forState:UIControlStateNormal];
        }
        [self.matchNoticeView show];
        
    }
    
    //设置上次播放时间
    NSInteger lastPlayTime = _model.lastPlayTime;
    
    if (lastPlayTime > 0) {
        [self.lastTimeNoticeView.titleButton setTitle:[NSString stringWithFormat:@"点击继续观看: %@", ddp_mediaFormatterTime((int)lastPlayTime)] forState:UIControlStateNormal];
        @weakify(self)
        [self.lastTimeNoticeView.titleButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            [self.player jump:(int)time completionHandler:nil];
        }];
        [self.lastTimeNoticeView show];
    }
}

- (void)updateCurrentTime:(NSString *)currentTime totalTime:(NSString *)totalTime progress:(CGFloat)progress {
    self.currentTimeLabel.text = currentTime;
    self.totalTimeLabel.text = totalTime;
    if (_isSliderNoActionNotice == NO) {
        self.progressSlider.value = progress;
    }
}

- (void)updateWithPlayerStatus:(DDPMediaPlayerStatus)status {
    switch (status) {
        case DDPMediaPlayerStatusPlaying:
            self.playButton.selected = NO;
            break;
        default:
            self.playButton.selected = YES;
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //记录滑动手势一开始点击的位置
    _panGestureTouchPoint = [touch locationInView:self];
    return YES;
}

#pragma mark - 私有方法
- (void)touchSettingButton:(UIButton *)button {
    if (self.configPanelView.isShow) {
        [self.configPanelView dismissWithAnimate:NO];
    }
    else {
        [self.configPanelView showWithAnimate:NO];
        [self pauserTimer];
    }
    
    [self animate:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)animate:(dispatch_block_t)animateBlock completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:animateBlock completion:completion];
}

- (void)touchSendDanmakuButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(interfaceViewDidTouchSendDanmakuButton)]) {
        [self.delegate interfaceViewDidTouchSendDanmakuButton];
    }
}

- (void)resetTimer {
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:AUTO_DISS_MISS_TIME];
}

- (void)pauserTimer {
    self.timer.fireDate = [NSDate distantFuture];
}

#pragma mark UI
- (void)touchBackButton:(UIButton *)sender {
    [self.viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchPlayButton {
    if ([self.player isPlaying]) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}

- (void)touchSliderDown:(UISlider *)slider {
    _isSliderNoActionNotice = YES;
}

- (void)touchSliderUp:(UISlider *)slider {
    @weakify(self)
    [self.player setPosition:slider.value completionHandler:^(NSTimeInterval time) {
        @strongify(self)
        if (!self) return;
        
        self->_isSliderNoActionNotice = NO;
        if ([self.delegate respondsToSelector:@selector(interfaceView:touchSliderWithTime:)]) {
            [self.delegate interfaceView:self touchSliderWithTime:time];
        }
        MBProgressHUD *aHUD = [self viewWithTag:HUD_TAG];
        [aHUD hideAnimated:YES];
    }];
}

- (void)touchSlider:(UISlider *)slider {
    MBProgressHUD *aHUD = [self viewWithTag:HUD_TAG];
    if (aHUD == nil) {
        aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeDeterminateHorizontalBar InView:self];
        aHUD.label.numberOfLines = 0;
        aHUD.tag = HUD_TAG;
    }
    
    int length = [self.player length];
    NSString *time = [NSString stringWithFormat:@"%@/%@", ddp_mediaFormatterTime(length * slider.value), ddp_mediaFormatterTime(length)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSString *speed = nil;
    if (_sliderRate == slowRate) {
        speed = @"\n慢速";
    }
    else if (_sliderRate == normalRate) {
        speed = @"\n中速";
    }
    else {
        speed = @"\n快速";
    }
    
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:speed attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
    aHUD.label.attributedText = str;
    aHUD.progress = slider.value;
    
    [self resetTimer];
}

- (void)touchSwitch:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(interfaceView:touchDanmakuVisiableButton:)]) {
        [self.delegate interfaceView:self touchDanmakuVisiableButton:sender.on];
    }
}

- (void)touchSubTitleIndexButton {
    [self endEditing:YES];
    
    self.subTitleIndexView.currentVideoSubTitleIndex = self.player.currentSubtitleIndex;
    self.subTitleIndexView.videoSubTitlesIndexes = self.player.subtitleIndexs;
    self.subTitleIndexView.videoSubTitlesNames = self.player.subtitleTitles;
    [self.subTitleIndexView show];
}

- (void)touchScreenShotButton:(UIButton *)sender {
    sender.alpha = 0.2;
    [self.screenShotIndicatorView startAnimating];
    
    [self.player saveVideoSnapshotwithSize:CGSizeZero completionHandler:^(UIImage *image, NSError *error) {
        [self.screenShotIndicatorView stopAnimating];
        sender.alpha = 1;
        
        if (error) {
            [self showWithText:@"截图失败!"];
        }
        else {
            [self showWithText:@"截图成功!"];
        }
    }];
}

- (void)panScreen:(UIPanGestureRecognizer *)panGesture {
    UIGestureRecognizerState state = panGesture.state;
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateFailed) {
        if (_panType == InterfaceViewPanTypeProgress) {
            [self touchSliderUp:self.progressSlider];
        }
        
        _panType = InterfaceViewPanTypeInactive;
        [self.brightnessControlView dismiss];
        [self.volumeControlView dismiss];
    }
    else {
        if (_panType == InterfaceViewPanTypeInactive) {
            CGPoint point = [panGesture locationInView:self];
            
            CGPoint tempPoint = CGPointMake(point.x - _panGestureTouchPoint.x, point.y - _panGestureTouchPoint.y);

            //横向移动
            if (fabs(tempPoint.y) < 10) {
                //让slider不响应进度更新
                _panType = InterfaceViewPanTypeProgress;
                [self touchSliderDown:self.progressSlider];
            }
            //亮度调节
            else if (point.x < self.width / 2) {
                _panType = InterfaceViewPanTypeLight;
                [self.brightnessControlView showFromView:self];
            }
            //音量调节
            else {
                _panType = InterfaceViewPanTypeVolume;
                [self.volumeControlView showFromView:self];
            }
        }
        //进度调节
        else if (_panType == InterfaceViewPanTypeProgress) {
            float y = [panGesture locationInView:self].y;
            if (y >= 0 && y <= self.height / 3) {
                _sliderRate = slowRate;
            }
            else if (y >= self.height / 3 && y <= self.height * 2 / 3) {
                _sliderRate = normalRate;
            }
            else {
                _sliderRate = fastRate;
            }
            
            float x = self.player.position + ([panGesture translationInView:nil].x / self.width) * _sliderRate;
            self.progressSlider.value = x;
            [self touchSlider:self.progressSlider];
        }
        //亮度和音量调节
        else {
            float rate = -[panGesture translationInView:nil].y;
            [panGesture setTranslation:CGPointZero inView:nil];
            rate /= self.height;
            
            //改变系统音量
            if (_panType == InterfaceViewPanTypeVolume) {
                if (_lastPanDate == nil || fabs([_lastPanDate timeIntervalSinceDate:[NSDate date]]) > 0.015) {
                    CGFloat value = self.volumeControlView.progress + rate;
                    self.volumeControlView.progress = value;
                    self.mpVolumeView.ddp_volume = value;
                    _lastPanDate = [NSDate date];
                    [self.volumeControlView resetTimer];
                }
            }
            else {
                float brightness = [UIScreen mainScreen].brightness;
                brightness += rate;
                self.brightnessControlView.progress = brightness;
                [[UIScreen mainScreen] setBrightness:brightness];
            }
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)sender {
    if (self.isShow) {
        [self dismissWithAnimate:YES];
    }
    else {
        [self showWithAnimate:YES];
    }
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] init];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"comment_gradual_gray"] yy_imageByRotate180]];
        bgImgView.alpha = 0.8;
        [_topView addSubview:bgImgView];
        [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(_topView);
        }];
        
        
        [_topView addSubview:self.titleLabel];
        [_topView addSubview:self.backButton];
        [_topView addSubview:self.settingButton];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(20);
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(30 + ddp_isPad() * 20);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right).mas_offset(10);
        }];
        
        [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_offset(-10);
        }];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_gradual_gray"]];
        bgImgView.alpha = 0.8;
        [_bottomView addSubview:bgImgView];
        [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(_bottomView);
        }];
        
        [_bottomView addSubview:self.currentTimeLabel];
        [_bottomView addSubview:self.progressSlider];
        [_bottomView addSubview:self.totalTimeLabel];
        [_bottomView addSubview:self.sendDanmakuButton];
        [_bottomView addSubview:self.danmakuHideSwitch];
        [_bottomView addSubview:self.subTitleIndexButton];
        [_bottomView addSubview:self.screenShotButton];
        [_bottomView addSubview:self.screenShotIndicatorView];
        
        [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.centerY.equalTo(self.progressSlider);
            make.width.mas_equalTo(60);
        }];
        
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.currentTimeLabel.mas_right).mas_offset(10);
            make.top.mas_offset(15);
        }];
        
        [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.progressSlider);
            make.right.mas_offset(-10);
            make.left.equalTo(self.progressSlider.mas_right).mas_offset(10);
            make.width.mas_equalTo(self.currentTimeLabel);
        }];
        
        [self.danmakuHideSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.currentTimeLabel.mas_bottom).mas_offset(15);
            make.right.mas_offset(-10);
            make.bottom.mas_offset(-15);
        }];
        
        [self.sendDanmakuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.danmakuHideSwitch.mas_left).mas_offset(-20);
            make.centerY.equalTo(self.danmakuHideSwitch);
        }];
        
        [self.subTitleIndexButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(20);
            make.centerY.equalTo(self.danmakuHideSwitch);
        }];
        
        [self.screenShotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.subTitleIndexButton);
            make.left.equalTo(self.subTitleIndexButton.mas_right).mas_offset(10);
        }];
        
        [self.screenShotIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.screenShotButton);
        }];
        
    }
    return _bottomView;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"comment_back_item"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(touchBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)currentTimeLabel {
    if (_currentTimeLabel == nil) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont ddp_smallSizeFont];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (_totalTimeLabel == nil) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont ddp_smallSizeFont];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UISlider *)progressSlider {
    if (_progressSlider == nil) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumTrackTintColor = [UIColor ddp_mainColor];
        [_progressSlider addTarget:self action:@selector(touchSliderDown:) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(touchSliderUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [_progressSlider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

- (UIButton *)sendDanmakuButton {
    if (_sendDanmakuButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(30, 5);
        _sendDanmakuButton = aButton;
        _sendDanmakuButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_sendDanmakuButton setTitle:@"吐个嘈~" forState:UIControlStateNormal];
        [_sendDanmakuButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
        _sendDanmakuButton.layer.cornerRadius = 6;
        _sendDanmakuButton.layer.masksToBounds = YES;
        _sendDanmakuButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [_sendDanmakuButton addTarget:self action:@selector(touchSendDanmakuButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendDanmakuButton;
}

- (DDPEdgeButton *)settingButton {
    if (_settingButton == nil) {
        _settingButton = [[DDPEdgeButton alloc] init];
        _settingButton.inset = CGSizeMake(20, 6);
        [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
        _settingButton.titleLabel.font = [UIFont ddp_bigSizeFont];
        [_settingButton addTarget:self action:@selector(touchSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        [_settingButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_settingButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _settingButton;
}

- (UISwitch *)danmakuHideSwitch {
    if (_danmakuHideSwitch == nil) {
        _danmakuHideSwitch = [[UISwitch alloc] init];
        _danmakuHideSwitch.onTintColor = [UIColor ddp_mainColor];
        _danmakuHideSwitch.on = YES;
        [_danmakuHideSwitch addTarget:self action:@selector(touchSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _danmakuHideSwitch;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
        _playButton.adjustsImageWhenHighlighted = NO;
        [_playButton addTarget:self action:@selector(touchPlayButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)subTitleIndexButton {
    if (_subTitleIndexButton == nil) {
        DDPEdgeButton *_aButton = [[DDPEdgeButton alloc] init];
        [_aButton setTitle:@"字幕" forState:UIControlStateNormal];
        _aButton.titleLabel.font = [UIFont ddp_bigSizeFont];
        _aButton.inset = CGSizeMake(10, 10);
        _subTitleIndexButton = _aButton;
        [_subTitleIndexButton addTarget:self action:@selector(touchSubTitleIndexButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subTitleIndexButton;
}

- (UIButton *)screenShotButton {
    if (_screenShotButton == nil) {
        DDPEdgeButton *_aButton = [[DDPEdgeButton alloc] init];
        _aButton.inset = CGSizeMake(10, 10);
        _aButton.adjustsImageWhenHighlighted = YES;
        _screenShotButton = _aButton;
        [_screenShotButton setImage:[UIImage imageNamed:@"player_screen_shot"] forState:UIControlStateNormal];
        [_screenShotButton addTarget:self action:@selector(touchScreenShotButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenShotButton;
}

- (UIActivityIndicatorView *)screenShotIndicatorView {
    if (_screenShotIndicatorView == nil) {
        _screenShotIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _screenShotIndicatorView;
}

- (DDPPlayerConfigPanelView *)configPanelView {
    if (_configPanelView == nil) {
        _configPanelView = [[DDPPlayerConfigPanelView alloc] initWithFrame:CGRectMake(0, 0, self.width * CONFIG_VIEW_WIDTH_RATE, self.height)];
        [self addSubview:_configPanelView];
    }
    return _configPanelView;
}

- (DDPPlayerInterfaceHolderView *)holdView {
    if (_holdView == nil) {
        _holdView = [[DDPPlayerInterfaceHolderView alloc] initWithFrame:self.bounds];
        @weakify(self)
        [_holdView setTouchViewCallBack:^{
            @strongify(self)
            if (!self) return;
            
            //点击则重设计时器
            if (self.configPanelView.isShow == false) {
                [self resetTimer];                
            }
        }];
        
        [_holdView addSubview:self.topView];
        [_holdView addSubview:self.bottomView];
        [_holdView addSubview:self.playButton];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-20);
            make.bottom.equalTo(self.bottomView.mas_top).mas_offset(-10 - ddp_isPad() * 10);
        }];
        
        [self addSubview:_holdView];
    }
    return _holdView;
}

- (UIView *)gestureView {
    if (_gestureView == nil) {
        _gestureView = [[UIView alloc] init];
        
        //手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [_gestureView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *pauseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPlayButton)];
        pauseGesture.numberOfTapsRequired = 2;
        [_gestureView addGestureRecognizer:pauseGesture];
        [tapGesture requireGestureRecognizerToFail:pauseGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panScreen:)];
        panGesture.delegate = self;
        [_gestureView addGestureRecognizer:panGesture];
        
        [self addSubview:_gestureView];
    }
    return _gestureView;
}

- (DDPPlayerSubTitleIndexView *)subTitleIndexView {
    if (_subTitleIndexView == nil) {
        _subTitleIndexView = [[DDPPlayerSubTitleIndexView alloc] initWithFrame:self.bounds];
        
        //字幕视图
        @weakify(self)
        [_subTitleIndexView setSelectedIndexCallBack:^(int index) {
            @strongify(self)
            if (!self) return;
            
            self.player.currentSubtitleIndex = index;
        }];
        
        
        [_subTitleIndexView setDidTapEmptyViewCallBack:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(interfaceViewDidTapSubTitleIndexEmptyView)]) {
                [self.delegate interfaceViewDidTapSubTitleIndexEmptyView];
            }
        }];
    }
    return _subTitleIndexView;
}

- (DDPPlayerMatchView *)matchNoticeView {
    if (_matchNoticeView == nil) {
        _matchNoticeView = [[DDPPlayerMatchView alloc] init];
        @weakify(self)
        [_matchNoticeView.customMathButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(interfaceViewDidTouchCustomMatchButton)]) {
                [self.delegate interfaceViewDidTouchCustomMatchButton];
            }
        }];
        
        [self addSubview:_matchNoticeView];
    }
    return _matchNoticeView;
}

- (DDPPlayerNoticeView *)lastTimeNoticeView {
    if (_lastTimeNoticeView == nil) {
        _lastTimeNoticeView = [[DDPPlayerNoticeView alloc] init];
        _lastTimeNoticeView.autoDismissTime = 5;
        [self addSubview:_lastTimeNoticeView];
    }
    return _lastTimeNoticeView;
}

- (DDPControlView *)volumeControlView {
    if (_volumeControlView == nil) {
        _volumeControlView = [[DDPControlView alloc] initWithImage:[UIImage imageNamed:@"player_volume"]];
        _volumeControlView.progress = [AVAudioSession sharedInstance].outputVolume;
        
        @weakify(self)
        _volumeControlView.dismissCallBack = ^(BOOL finish) {
            @strongify(self)
            if (!self) return;
            
            self.lastPanDate = nil;
        };
    }
    return _volumeControlView;
}

- (DDPControlView *)brightnessControlView {
    if (_brightnessControlView == nil) {
        _brightnessControlView = [[DDPControlView alloc] initWithImage:[UIImage imageNamed:@"player_brightness"]];
        _brightnessControlView.progress = [UIScreen mainScreen].brightness;
    }
    return _brightnessControlView;
}

- (DDPVolumeView *)mpVolumeView {
    if (_mpVolumeView == nil) {
        _mpVolumeView = [[DDPVolumeView alloc] init];
        _mpVolumeView.clipsToBounds = true;
    }
    return _mpVolumeView;
}

@end
