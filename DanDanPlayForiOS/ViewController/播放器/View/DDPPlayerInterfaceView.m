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

#import "DDPPlayerSendDanmakuConfigView.h"
#import "DDPPlayerMatchView.h"
#import "DDPControlView.h"
#import "DDPMediaPlayer.h"


#import <MediaPlayer/MediaPlayer.h>
#import <YYKeyboardManager.h>
#import "DDPVideoModel+Tools.h"
#import <AVFoundation/AVFoundation.h>

#import "DDPMatchViewController.h"
#import "DDPPlayerControlAnimater.h"
#import "DDPPlayerSelectedIndexView.h"
#import "DDPPlayerSubTitleIndexViewMediator.h"
#import "DDPPlayerAudioChannelViewMediator.h"
#import "UIApplication+DDPTools.h"

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

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;


@property (strong, nonatomic) UIScrollView *titlsScrollView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (weak, nonatomic) IBOutlet UISwitch *danmakuHideSwitch;

@property (weak, nonatomic) IBOutlet UIButton *subTitleIndexButton;
@property (weak, nonatomic) IBOutlet UIButton *audioChannelIndexButton;
@property (weak, nonatomic) IBOutlet UIButton *screenShotButton;

/**
 发弹幕按钮
 */
@property (weak, nonatomic) IBOutlet DDPEdgeButton *sendDanmakuButton;

@property (weak, nonatomic) IBOutlet UIImageView *topBgImgView;

@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImgView;

/**
 手势视图
 */
@property (weak, nonatomic) IBOutlet UIView *gestureView;

@property (weak, nonatomic) DDPMediaPlayer *player;

/**
 处理一些点击事件
 */
@property (weak, nonatomic) IBOutlet DDPPlayerInterfaceHolderView *holdView;

/**
 自定义音量需要用到
 */
@property (strong, nonatomic) DDPVolumeView *mpVolumeView;


@property (strong, nonatomic) NSTimer *timer;
//上次滑动时间
@property (strong, nonatomic) NSDate *lastPanDate;

@property (weak, nonatomic) DDPPlayerConfigPanelViewController *configPanelVC;


/**
 字幕代理器
 */
@property (strong, nonatomic) DDPPlayerSubTitleIndexViewMediator *subTitleIndexViewMediator;

/**
 音频轨道代理器
 */
@property (strong, nonatomic) DDPPlayerAudioChannelViewMediator *audioChannelViewMediator;
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
    
    __weak UIActivityIndicatorView *_indicatorView;
    __weak DDPControlView *_volumeView;
    __weak DDPControlView *_brightnessView;
    __weak DDPPlayerMatchView *_matchNoticeView;
    __weak DDPPlayerNoticeView *_lastTimeNoticeView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    _show = YES;
    _panGestureTouchPoint = CGPointZero;
    
    [self.topView addSubview:self.titlsScrollView];
    [self.titlsScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backButton.mas_right).mas_equalTo(10);
        make.right.mas_equalTo(self.settingButton.mas_left).mas_equalTo(-10);
        make.height.centerY.mas_equalTo(self.backButton);
    }];
    
    self.backButton.ddp_hitTestSlop = UIEdgeInsetsMake(-20, -30, -20, -30);
    self.settingButton.ddp_hitTestSlop = UIEdgeInsetsMake(-20, -20, -20, -20);
    self.subTitleIndexButton.ddp_hitTestSlop = UIEdgeInsetsMake(-20, -10, -20, -10);
    self.audioChannelIndexButton.ddp_hitTestSlop = UIEdgeInsetsMake(-20, -10, -20, -10);
    self.screenShotButton.ddp_hitTestSlop = UIEdgeInsetsMake(-20, -10, -20, -10);
    
    self.currentTimeLabel.font = [UIFont ddp_smallSizeFont];
    self.totalTimeLabel.font = [UIFont ddp_smallSizeFont];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    
    self.progressSlider.minimumTrackTintColor = [UIColor ddp_mainColor];
    
    self.sendDanmakuButton.titleLabel.font = [UIFont ddp_normalSizeFont];
    self.sendDanmakuButton.inset = CGSizeMake(30, 5);
    [self.sendDanmakuButton setTitle:@"吐个槽~" forState:UIControlStateNormal];
    [self.sendDanmakuButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
    self.sendDanmakuButton.layer.cornerRadius = 6;
    self.sendDanmakuButton.layer.masksToBounds = YES;
    self.sendDanmakuButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    
//    if (ddp_appType == DDPAppTypeReview) {
//        self.sendDanmakuButton.hidden = true;
//    }
    
    self.settingButton.titleLabel.font = [UIFont ddp_bigSizeFont];
    
    self.danmakuHideSwitch.onTintColor = [UIColor ddp_mainColor];
    
    self.subTitleIndexButton.titleLabel.font = [UIFont ddp_bigSizeFont];
    self.audioChannelIndexButton.titleLabel.font = [UIFont ddp_bigSizeFont];
    
    //加入最底层
    [self insertSubview:self.mpVolumeView belowSubview:self.gestureView];
    
    {
        @weakify(self)
        [self.holdView setTouchViewCallBack:^{
            @strongify(self)
            if (!self) return;
            
            //点击则重设计时器
            if (self.configPanelVC == nil) {
                [self resetTimer];
            }
        }];
    }
    
    {
        //手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [self.gestureView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *pauseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPlayButton)];
        pauseGesture.numberOfTapsRequired = 2;
        [self.gestureView addGestureRecognizer:pauseGesture];
        [tapGesture requireGestureRecognizerToFail:pauseGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panScreen:)];
        panGesture.delegate = self;
        [self.gestureView addGestureRecognizer:panGesture];
    }
    
    //监听音量变化
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession addObserver:self forKeyPath:DDP_KEYPATH(audioSession, outputVolume) options:NSKeyValueObservingOptionNew context:nil];
    
    [self resetTimer];
}

+ (instancetype)creatWithPlayer:(DDPMediaPlayer *)player {
    let view = [DDPPlayerInterfaceView fromXib];
    view.player = player;
    return view;
}

- (void)setPlayer:(DDPMediaPlayer *)player {
    _player = player;
    self.subTitleIndexViewMediator.player = player;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //物理按键调节音量
    if ([keyPath isEqualToString:DDP_KEYPATH([AVAudioSession sharedInstance], outputVolume)]) {
        
        if (_lastPanDate != nil) return;
        
        CGFloat volume = [change[NSKeyValueChangeNewKey] floatValue];
        
        DDPControlView *volumeView = _volumeView;
        if (volumeView == nil) {
            volumeView = [self creatVolumeControlView];
            _volumeView = volumeView;
        }
        
        if (volumeView.isShowing == NO) {
            [volumeView showFromView:self];
        }
        
        [volumeView dismissAfter:1];
        volumeView.progress = volume;
    }
}

- (void)dealloc {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession removeObserver:self forKeyPath:DDP_KEYPATH(audioSession, outputVolume)];
}

- (void)setDelegate:(id<DDPPlayerInterfaceViewDelegate>)delegate {
    _delegate = delegate;
    
    self.configPanelVC.delegate = _delegate;
}

- (void)showWithAnimate:(BOOL)flag {
    if (_show == NO) {
        _show = YES;
        self.topView.transform = CGAffineTransformMakeTranslation(0, -30);
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, 30);
//        [self.titleView startAnimate];
        
        let action = ^{
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
        [self dismissConfigPanelVC];
//        [self.configPanelVC dismissViewControllerAnimated:flag completion:nil];
        
        let action = ^{
            self.holdView.alpha = 0;
            self.topView.transform = CGAffineTransformMakeTranslation(0, -30);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 30);
            [self.viewController setNeedsStatusBarAppearanceUpdate];
            if (@available(iOS 11.0, *)) {
                [self.viewController setNeedsUpdateOfHomeIndicatorAutoHidden];
            }
//            [self layoutIfNeeded];
        };
        
        if (flag) {
            [self animate:action completion:^(BOOL finished) {
//                [self.titleView stopAnimate];
            }];
        }
        else {
            action();
//            [self.titleView stopAnimate];
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
        NSString *danmakuCountStr = [NSString stringWithFormat:@"共%lu条弹幕", (unsigned long)_model.danmakus.collection.count];
        
        if (_matchNoticeView == nil) {
            _matchNoticeView = [self creatMatchNoticeView];
        }
        
        if (matchName.length) {
            _matchNoticeView.title = [matchName stringByAppendingFormat:@"\n%@", danmakuCountStr];
        }
        else {
            _matchNoticeView.title = danmakuCountStr;
        }
        
#if !DDPAPPTYPE
        [_matchNoticeView show];
#endif
        
    }
    
    //设置上次播放时间
    NSInteger lastPlayTime = _model.lastPlayTime;
    
    if (lastPlayTime > 0) {
        
        if (_lastTimeNoticeView == nil) {
            _lastTimeNoticeView = [self creatLastTimeNoticeView];
        }
        
        _lastTimeNoticeView.title = [NSString stringWithFormat:@"点击继续观看: %@", ddp_mediaFormatterTime((int)lastPlayTime)];
        @weakify(self)
        _lastTimeNoticeView.touchTitleCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            [self.player jump:(int)lastPlayTime completionHandler:nil];
        };
        
        [_lastTimeNoticeView show];
    }
    else {
        [_lastTimeNoticeView dismiss];
    }
}

- (void)updateCurrentTime:(NSString *)currentTime totalTime:(NSString *)totalTime progress:(CGFloat)progress {
    self.currentTimeLabel.text = currentTime;
    self.totalTimeLabel.text = totalTime;
    if (_isSliderNoActionNotice == NO) {
        self.progressSlider.value = progress;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //记录滑动手势一开始点击的位置
    _panGestureTouchPoint = [touch locationInView:self];
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return false;
}

#pragma mark - 私有方法

- (void)resetTimer {
//    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:AUTO_DISS_MISS_TIME];
    
    @weakify(self)
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:AUTO_DISS_MISS_TIME block:^(NSTimer * _Nonnull timer) {
        @strongify(self)
        if (!self) return;
        
        [self dismissWithAnimate:YES];
//        timer.fireDate = [NSDate distantFuture];
    } repeats:false];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)pauserTimer {
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)animate:(dispatch_block_t)animateBlock completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:animateBlock completion:completion];
}

- (DDPControlView *)creatVolumeControlView {
    let volumeControlView = [[DDPControlView alloc] initWithImage:[UIImage imageNamed:@"player_volume"]];
    volumeControlView.progress = [AVAudioSession sharedInstance].outputVolume;

    @weakify(self)
    volumeControlView.dismissCallBack = ^(BOOL finish) {
        @strongify(self)
        if (!self) return;

        self.lastPanDate = nil;
    };
    return volumeControlView;
}

- (DDPControlView *)creatBrightnessControlView {
    let brightnessControlView = [[DDPControlView alloc] initWithImage:[UIImage imageNamed:@"player_brightness"]];
    brightnessControlView.progress = [UIScreen mainScreen].brightness;
    return brightnessControlView;
}

- (DDPPlayerMatchView *)creatMatchNoticeView {
    let matchNoticeView = [[DDPPlayerMatchView alloc] init];
    @weakify(self)
    matchNoticeView.touchMatchButtonCallBack = ^{
        @strongify(self)
        if (!self) return;

        if ([self.delegate respondsToSelector:@selector(interfaceViewDidTouchCustomMatchButton)]) {
            [self.delegate interfaceViewDidTouchCustomMatchButton];
        }
    };
    
    [self addSubview:matchNoticeView];
    
    [matchNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.mas_equalTo(self.mas_safeAreaLayoutGuideLeft);
        } else {
            make.left.mas_equalTo(0);
        }
        make.centerY.mas_offset(-25);
    }];
    
    return matchNoticeView;
}

- (DDPPlayerNoticeView *)creatLastTimeNoticeView {
    let lastTimeNoticeView = [[DDPPlayerNoticeView alloc] init];
    lastTimeNoticeView.autoDismissTime = 5;
    [self addSubview:lastTimeNoticeView];
    [lastTimeNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.mas_equalTo(self.mas_safeAreaLayoutGuideLeft);
        } else {
            make.left.mas_equalTo(0);
        }
        make.top.equalTo(self->_matchNoticeView.mas_bottom).mas_offset(15);
    }];
    return lastTimeNoticeView;
}

- (DDPPlayerSelectedIndexView *)creatSubTitleIndexView {
    let subTitleIndexView = [DDPPlayerSelectedIndexView fromXib];
    subTitleIndexView.delegate = self.subTitleIndexViewMediator;
    subTitleIndexView.dataSource = self.subTitleIndexViewMediator;
    return subTitleIndexView;
}

- (DDPPlayerSelectedIndexView *)creatAudioChannelView {
    let subTitleIndexView = [DDPPlayerSelectedIndexView fromXib];
    subTitleIndexView.delegate = self.audioChannelViewMediator;
    subTitleIndexView.dataSource = self.audioChannelViewMediator;
    return subTitleIndexView;
}

- (void)dismissConfigPanelVC {
    
//    [self.tapGestureView removeFromSuperview];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.configPanelVC.view.left = self.viewController.view.width / 2;
    } completion:^(BOOL finished) {
        [self.configPanelVC willMoveToParentViewController:nil];
        [self.configPanelVC.view removeFromSuperview];
        [self.configPanelVC removeFromParentViewController];
        [self resetTimer];
    }];
}

- (void)showConfigPanelVC {
    if (self.configPanelVC != nil) {
        [self dismissConfigPanelVC];
        return;
    }
    
    @weakify(self)
    
    let vc = [[DDPPlayerConfigPanelViewController alloc] init];
    vc.delegate = self.delegate;
    vc.touchBgViewCallBack = ^{
        @strongify(self)
        if (!self) {
            return;
        }
        
        [self dismissConfigPanelVC];
    };
    self.configPanelVC = vc;
    
    [self.viewController addChildViewController:vc];
    [self.viewController.view addSubview:vc.view];
    [vc didMoveToParentViewController:self.viewController];
    
    self.configPanelVC.view.left = self.viewController.view.width / 2;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.configPanelVC.view.left = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    [self pauserTimer];
}

#pragma mark UI
- (IBAction)touchSettingButton:(UIButton *)button {
    [self showConfigPanelVC];
}

- (IBAction)touchSendDanmakuButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(interfaceViewDidTouchSendDanmakuButton)]) {
        [self.delegate interfaceViewDidTouchSendDanmakuButton];
    }
}


- (IBAction)touchBackButton:(UIButton *)sender {
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

- (IBAction)touchSliderDown:(UISlider *)slider {
    _isSliderNoActionNotice = YES;
}

- (IBAction)touchSliderUp:(UISlider *)slider {
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

- (IBAction)touchSlider:(UISlider *)slider {
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

- (IBAction)touchSwitch:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(interfaceView:touchDanmakuVisiableButton:)]) {
        [self.delegate interfaceView:self touchDanmakuVisiableButton:sender.on];
    }
}

- (IBAction)touchSubTitleIndexButton {
    [self endEditing:YES];
    
    let subTitleIndexView = [self creatSubTitleIndexView];
    [self addSubview:subTitleIndexView];
    [subTitleIndexView show];
}

- (IBAction)touchAudioChannelButton {
    [self endEditing:YES];
    
    let view = [self creatAudioChannelView];
    [self addSubview:view];
    [view show];
}

- (IBAction)touchScreenShotButton:(UIButton *)sender {
    sender.alpha = 0.2;
    
    [_indicatorView stopAnimating];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView = indicatorView;
    
    [self.player saveVideoSnapshotwithSize:CGSizeZero completionHandler:^(UIImage *image, NSError *error) {
        if (self->_indicatorView != nil) {
            [self->_indicatorView stopAnimating];
        }
        
        sender.alpha = 1;
        
        if (error) {
            [self showWithText:[NSString stringWithFormat:@"截图失败! 请在设置-%@-照片中检查权限是否开启", [UIApplication sharedApplication].appDisplayName] hideAfterDelay:2];
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
        [_brightnessView dismiss];
        [_volumeView dismiss];
    }
    else {
        if (_panType == InterfaceViewPanTypeInactive) {
            CGPoint point = [panGesture locationInView:self];
            
            CGPoint tempPoint = CGPointMake(point.x - _panGestureTouchPoint.x, point.y - _panGestureTouchPoint.y);

            //横向移动
            if (panGesture.numberOfTouches > 1 || (fabs(tempPoint.y) < 10)) {
                //让slider不响应进度更新
                _panType = InterfaceViewPanTypeProgress;
                [self touchSliderDown:self.progressSlider];
            }
            //亮度调节
            else if (point.x < self.width / 2) {
                _panType = InterfaceViewPanTypeLight;
                
                DDPControlView *controlView = _brightnessView;
                if (controlView == nil) {
                    controlView = [self creatBrightnessControlView];
                    _brightnessView = controlView;
                }
                [controlView showFromView:self];
            }
            //音量调节
            else {
                _panType = InterfaceViewPanTypeVolume;
                DDPControlView *volumeView = _volumeView;
                if (volumeView == nil) {
                    volumeView = [self creatVolumeControlView];
                    _volumeView = volumeView;
                }
                [volumeView showFromView:self];
            }
        }
        //进度调节
        else if (_panType == InterfaceViewPanTypeProgress) {
            
            let numberOfTouches = panGesture.numberOfTouches;
            if (numberOfTouches > 1) {
                if (numberOfTouches <= 1) {
                    _sliderRate = slowRate;
                } else if (numberOfTouches > 1 && numberOfTouches <= 2) {
                    _sliderRate = normalRate;
                } else {
                    _sliderRate = fastRate;
                }
            } else {
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
                    CGFloat value = _volumeView.progress + rate;
                    _volumeView.progress = value;
                    self.mpVolumeView.ddp_volume = value;
                    _lastPanDate = [NSDate date];
                    [_volumeView resetTimer];
                }
            }
            else {
                float brightness = [UIScreen mainScreen].brightness;
                brightness += rate;
                _brightnessView.progress = brightness;
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

- (DDPVolumeView *)mpVolumeView {
    if (_mpVolumeView == nil) {
        _mpVolumeView = [[DDPVolumeView alloc] init];
        _mpVolumeView.clipsToBounds = true;
    }
    return _mpVolumeView;
}

//- (DDPMarqueeView *)titleView {
//    if (_titleView == nil) {
//        _titleView = [[DDPMarqueeView alloc] init];
//        _titleView.label.textColor = [UIColor whiteColor];
//    }
//    return _titleView;
//}

- (DDPPlayerSubTitleIndexViewMediator *)subTitleIndexViewMediator {
    if (_subTitleIndexViewMediator == nil) {
        _subTitleIndexViewMediator = [[DDPPlayerSubTitleIndexViewMediator alloc] init];
        @weakify(self)
        _subTitleIndexViewMediator.didTapSubTitleEmptyViewCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(interfaceViewDidTapSubTitleIndexEmptyView)]) {
                [self.delegate interfaceViewDidTapSubTitleIndexEmptyView];
            }
        };
        _subTitleIndexViewMediator.player = [DDPCacheManager shareCacheManager].mediaPlayer;
    }
    return _subTitleIndexViewMediator;
}

- (DDPPlayerAudioChannelViewMediator *)audioChannelViewMediator {
    if (_audioChannelViewMediator == nil) {
        _audioChannelViewMediator = [[DDPPlayerAudioChannelViewMediator alloc] init];
        _audioChannelViewMediator.player = [DDPCacheManager shareCacheManager].mediaPlayer;
    }
    return _audioChannelViewMediator;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
    }
    return _titleLabel;
}

- (UIScrollView *)titlsScrollView {
    if (_titlsScrollView == nil) {
        _titlsScrollView = [[UIScrollView alloc] init];
//        _titlsScrollView.bounces = false;
        _titlsScrollView.showsHorizontalScrollIndicator = false;
        [_titlsScrollView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.centerY.mas_equalTo(_titlsScrollView);
        }];
    }
    return _titlsScrollView;
}

@end
