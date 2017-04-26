//
//  PlayerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/21.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerViewController.h"
#import "MatchViewController.h"

#import "PlayerInterfaceView.h"
#import "JHMediaPlayer.h"
#import "JHDanmakuRender.h"
#import "DanmakuManager.h"
#import "PlayerConfigPanelView.h"
#import "PlayerSendDanmakuConfigView.h"

#define CONFIG_VIEW_WIDTH_RATE 0.4

@interface PlayerViewController ()<UITextFieldDelegate, JHMediaPlayerDelegate, JHDanmakuEngineDelegate, PlayerConfigPanelViewDelegate>
@property (strong, nonatomic) PlayerInterfaceView *interfaceView;
@property (strong, nonatomic) UIView *gestureView;
@property (strong, nonatomic) JHMediaPlayer *player;
@property (strong, nonatomic) JHDanmakuEngine *danmakuEngine;
@property (strong, nonatomic) PlayerConfigPanelView *configPanelView;
@property (strong, nonatomic) PlayerSendDanmakuConfigView *sendDanmakuConfigView;
@end

@implementation PlayerViewController
{
    //进度条是否不响应通知
    BOOL _isSliderNoActionNotice;
    NSMutableDictionary <NSNumber *, NSMutableArray<JHBaseDanmaku *>*> *_danmakuDic;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"danmakuFont" options:NSKeyValueObservingOptionNew context:nil];
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"danmakuSpeed" options:NSKeyValueObservingOptionNew context:nil];
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"danmakuShadowStyle" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.danmakuEngine.canvas mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CacheManager shareCacheManager].subtitleProtectArea) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.mas_offset(-HEIGHT * 0.12);
        }
        else {
            make.edges.mas_equalTo(0);
        }
    }];
    
    [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.interfaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.player.mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.configPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
        make.left.equalTo(self.view.mas_right);
    }];
    
    [self reload];
}

- (void)setModel:(VideoModel *)model {
    _model = model;
    [CacheManager shareCacheManager].currentPlayVideoModel = _model;
    if (self.isViewLoaded) {
        [self reload];
        [self.player play];
    }
}

- (void)dealloc {
    [self.player stop];
    [self.danmakuEngine stop];
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"danmakuFont"];
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"danmakuSpeed"];
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"danmakuShadowStyle"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"danmakuFont"]) {
        UIFont *font = change[NSKeyValueChangeNewKey];
        self.danmakuEngine.globalFont = font;
    }
    else if ([keyPath isEqualToString:@"danmakuSpeed"]) {
        float speed = [change[NSKeyValueChangeNewKey] floatValue];
        [self.danmakuEngine setSpeed:speed];
    }
    else if ([keyPath isEqualToString:@"danmakuShadowStyle"]) {
        JHDanmakuShadowStyle style = [change[NSKeyValueChangeNewKey] integerValue];
        self.danmakuEngine.globalShadowStyle = style;
    }
}

#pragma mark - JHMediaPlayerDelegate
- (void)mediaPlayer:(JHMediaPlayer *)player progress:(float)progress currentTime:(NSString *)currentTime totalTime:(NSString *)totalTime {
    self.interfaceView.currentTimeLabel.text = currentTime;
    self.interfaceView.totalTimeLabel.text = totalTime;
    if (_isSliderNoActionNotice == NO) {
        self.interfaceView.progressSlider.value = progress;
    }
    
}

- (void)mediaPlayer:(JHMediaPlayer *)player statusChange:(JHMediaPlayerStatus)status {
    switch (status) {
        case JHMediaPlayerStatusPlaying:
            self.interfaceView.playButton.selected = NO;
            [self.danmakuEngine start];
            break;
        case JHMediaPlayerStatusStop:
        {
            PlayerPlayMode mode = [CacheManager shareCacheManager].playMode;
            //单集循环
            if (mode == PlayerPlayModeSingleCircle) {
                self.model = self.model;
            }
            //列表循环
            else if (mode == PlayerPlayModeCircle) {
                if (self.model == [CacheManager shareCacheManager].videoModels.lastObject) {
                    [self playerConfigPanelView:self.configPanelView didSelectedModel:[CacheManager shareCacheManager].videoModels.firstObject];
//                    self.model = [CacheManager shareCacheManager].videoModels.firstObject;
                }
                else {
                    NSInteger index = [[CacheManager shareCacheManager].videoModels indexOfObject:self.model];
                    if (index != NSNotFound && index + 1 < [CacheManager shareCacheManager].videoModels.count) {
                        [self playerConfigPanelView:self.configPanelView didSelectedModel:[CacheManager shareCacheManager].videoModels[index + 1]];
//                        self.model = [CacheManager shareCacheManager].videoModels[index + 1];
                    }
                }
            }
            else if (mode == PlayerPlayModeOrder) {
                NSInteger index = [[CacheManager shareCacheManager].videoModels indexOfObject:self.model];
                if (index != NSNotFound && index + 1 < [CacheManager shareCacheManager].videoModels.count) {
                    [self playerConfigPanelView:self.configPanelView didSelectedModel:[CacheManager shareCacheManager].videoModels[index + 1]];
                }
            }
            
//            [self.configPanelView reloadData];
        }
            break;
        default:
            self.interfaceView.playButton.selected = YES;
            [self.danmakuEngine pause];
            break;
    }
}

#pragma mark - JHDanmakuEngineDelegate
- (NSArray <__kindof JHBaseDanmaku*>*)danmakuEngine:(JHDanmakuEngine *)danmakuEngine didSendDanmakuAtTime:(NSUInteger)time {
    return _danmakuDic[@(time)];
}

#pragma mark - PlayerConfigPanelViewDelegate
- (void)playerConfigPanelView:(PlayerConfigPanelView *)view didSelectedModel:(VideoModel *)model {
    
    void(^jumpToMatchVCAction)() = ^{
        MatchViewController *vc = [[MatchViewController alloc] init];
        vc.model = model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    if ([CacheManager shareCacheManager].openFastMatch) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = danmakusProgressToString(progress);
        } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
            model.danmakus = responseObject;
            [aHUD hideAnimated:YES];
            
            if (responseObject == nil) {
                jumpToMatchVCAction();
            }
            else {
                self.model = model;
            }
        }];
    }
    else {
        jumpToMatchVCAction();
    }
}

- (void)playerConfigPanelView:(PlayerConfigPanelView *)view didTouchStepper:(CGFloat)value {
    self.danmakuEngine.offsetTime = value;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length) {
        
        NSUInteger episodeId = [[CacheManager shareCacheManager] episodeIdWithVideoModel:self.model];
        if (episodeId == 0) return NO;
        
        UIColor *color = self.sendDanmakuConfigView.color;
        JHUser *user = [CacheManager shareCacheManager].user;
        
        JHDanmaku *danmaku = [[JHDanmaku alloc] init];
        danmaku.color = color.red * 256 * 256 * 255 + color.green * 256 * 255 + color.blue * 255;
        danmaku.time = self.player.currentTime;
        danmaku.mode = self.sendDanmakuConfigView.danmakuMode;
        danmaku.token = user.token;
        danmaku.userId = user.identity;
        danmaku.message = textField.text;
        
        [self touchInteractionView];
        [CommentNetManager launchDanmakuWithModel:danmaku episodeId:episodeId completionHandler:^(NSError *error) {
            if (error) {
                [MBProgressHUD showWithText:@"发送失败"];
            }
            else {
                [MBProgressHUD showWithText:@"发送成功"];
                JHBaseDanmaku *sendDanmaku = [DanmakuManager converDanmaku:danmaku];
                NSUInteger appearTime = (NSInteger)sendDanmaku.appearTime;
                if (_danmakuDic[@(appearTime)] == nil) {
                    _danmakuDic[@(appearTime)] = [NSMutableArray array];
                }
                [_danmakuDic[@(appearTime)] appendObject:sendDanmaku];
                [self.danmakuEngine sendDanmaku:sendDanmaku];
            }
        }];
    }
    return YES;
}

#pragma mark - 私有方法
- (void)touchInteractionView {
    //显示
    if (self.interfaceView.alpha == 0) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.interfaceView.alpha = 1;
        } completion:nil];
    }
    //隐藏
    else {
        [self.view endEditing:YES];
        if (self.configPanelView.show) {
            [self touchSettingButton];
        }
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.interfaceView.alpha = 0;
        } completion:nil];
    }
}

- (void)touchBackButton:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
        
        [self.danmakuEngine setCurrentTime:time];
        self->_isSliderNoActionNotice = NO;
        MBProgressHUD *aHUD = [self.view viewWithTag:1000];
        [aHUD hideAnimated:YES];
    }];
}

- (void)touchSlider:(UISlider *)slider {
    MBProgressHUD *aHUD = [self.view viewWithTag:1000];
    if (aHUD == nil) {
        aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeDeterminateHorizontalBar InView:self.view];
        aHUD.tag = 1000;
    }
    
    int length = [self.player length];
    aHUD.label.text = [NSString stringWithFormat:@"%@/%@", jh_mediaFormatterTime(length * slider.value), jh_mediaFormatterTime(length)];
    aHUD.progress = slider.value;
}

- (void)panScreen:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self touchSliderDown:self.interfaceView.progressSlider];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self touchSliderUp:self.interfaceView.progressSlider];
    }
    else {
        float x = self.player.position + ([panGesture translationInView:nil].x / self.view.width);
        self.interfaceView.progressSlider.value = x;
        [self touchSlider:self.interfaceView.progressSlider];
    }
    
}

- (void)touchSettingButton {
    
    self.configPanelView.show = !self.configPanelView.show;
    
    if (self.configPanelView.show == NO) {
        [self.configPanelView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.equalTo(self.view.mas_right);
            make.width.mas_equalTo(self.view.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
        }];
    }
    else {
        [self.configPanelView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            make.width.mas_equalTo(self.view.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
        }];
    }
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)touchSwitch:(UISwitch *)sender {
    self.danmakuEngine.canvas.hidden = !sender.on;
}

- (void)touchSendDanmakuConfigButton {
    [[UIApplication sharedApplication].keyWindow addSubview:self.sendDanmakuConfigView];
    [self.sendDanmakuConfigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.sendDanmakuConfigView show];
}

- (void)reload {
    _danmakuDic = [DanmakuManager converDanmakus:_model.danmakus.collection];
    self.interfaceView.titleLabel.text = _model.fileName;
    [self.player setMediaURL:_model.fileURL];
    self.danmakuEngine.currentTime = 0;
}

#pragma mark - 懒加载
- (PlayerInterfaceView *)interfaceView {
    if (_interfaceView == nil) {
        _interfaceView = [[PlayerInterfaceView alloc] init];
        [_interfaceView.backButton addTarget:self action:@selector(touchBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [_interfaceView.playButton addTarget:self action:@selector(touchPlayButton) forControlEvents:UIControlEventTouchUpInside];
        [_interfaceView.progressSlider addTarget:self action:@selector(touchSliderDown:) forControlEvents:UIControlEventTouchDown];
        [_interfaceView.progressSlider addTarget:self action:@selector(touchSliderUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [_interfaceView.progressSlider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventValueChanged];
        [_interfaceView.settingButton addTarget:self action:@selector(touchSettingButton) forControlEvents:UIControlEventTouchUpInside];
        [_interfaceView.danmakuHideSwitch addTarget:self action:@selector(touchSwitch:) forControlEvents:UIControlEventValueChanged];
        [_interfaceView.sendDanmakuConfigButton addTarget:self action:@selector(touchSendDanmakuConfigButton) forControlEvents:UIControlEventTouchUpInside];
        _interfaceView.sendDanmakuTextField.delegate = self;
        [self.view insertSubview:_interfaceView aboveSubview:self.gestureView];
    }
    return _interfaceView;
}

- (UIView *)gestureView {
    if (_gestureView == nil) {
        _gestureView = [[UIView alloc] init];
        UITapGestureRecognizer *showInteractionViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchInteractionView)];
        [_gestureView addGestureRecognizer:showInteractionViewGesture];
        
        UITapGestureRecognizer *pauseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPlayButton)];
        pauseGesture.numberOfTapsRequired = 2;
        [_gestureView addGestureRecognizer:pauseGesture];
        
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panScreen:)];
        [_gestureView addGestureRecognizer:panGesture];
        
        [self.view insertSubview:_gestureView aboveSubview:self.danmakuEngine.canvas];
    }
    return _gestureView;
}

- (JHMediaPlayer *)player {
    if (_player == nil) {
        _player = [[JHMediaPlayer alloc] init];
        _player.delegate = self;
        [self.view addSubview:_player.mediaView];
    }
    return _player;
}

- (JHDanmakuEngine *)danmakuEngine {
    if (_danmakuEngine == nil) {
        _danmakuEngine = [[JHDanmakuEngine alloc] init];
        _danmakuEngine.delegate = self;
        [_danmakuEngine setSpeed:[CacheManager shareCacheManager].danmakuSpeed];
        [self.view insertSubview:_danmakuEngine.canvas aboveSubview:self.player.mediaView];
    }
    return _danmakuEngine;
}

- (PlayerConfigPanelView *)configPanelView {
    if (_configPanelView == nil) {
        _configPanelView = [[PlayerConfigPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width * CONFIG_VIEW_WIDTH_RATE, self.view.height)];
        _configPanelView.delegate = self;
        [self.view addSubview:_configPanelView];
    }
    return _configPanelView;
}

- (PlayerSendDanmakuConfigView *)sendDanmakuConfigView {
    if (_sendDanmakuConfigView == nil) {
        _sendDanmakuConfigView = [[PlayerSendDanmakuConfigView alloc] initWithFrame:self.view.bounds];
    }
    return _sendDanmakuConfigView;
}

@end
