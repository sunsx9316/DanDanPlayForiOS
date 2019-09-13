//
//  DDPPlayViewController.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayViewController.h"
#import <Masonry/Masonry.h>
#import <JHDanmakuRender/JHDanmakuRender.h>
#import <DDPShare/DDPShare.h>
#import <DDPCategory/DDPCategory.h>
#import "DDPPlayerControlView.h"
#import "NSView+DDPTools.h"
#import "DDPMediaPlayer.h"
#import "DDPDanmakuManager.h"
#import "DDPPlayView.h"
#import "DDPPlayTopBar.h"
#import "DDPHUD.h"
#import "JHBaseDanmaku+DDPTools.h"

typedef NS_OPTIONS(NSUInteger, DDPDanmakuShieldType) {
    DDPDanmakuShieldTypeNone = kNilOptions,
    DDPDanmakuShieldTypeScrollToLeft = 1 << 0,
    DDPDanmakuShieldTypeScrollToRight = 1 << 1,
    DDPDanmakuShieldTypeScrollToTop = 1 << 2,
    DDPDanmakuShieldTypeScrollToBottom = 1 << 3,
    DDPDanmakuShieldTypeFloatAtTo = 1 << 4,
    DDPDanmakuShieldTypeFloatAtBottom = 1 << 5,
    DDPDanmakuShieldTypeColor = 1 << 6,
    
    DDPDanmakuShieldTypeScroll =
    DDPDanmakuShieldTypeScrollToLeft |
    DDPDanmakuShieldTypeScrollToRight |
    DDPDanmakuShieldTypeScrollToTop |
    DDPDanmakuShieldTypeScrollToBottom,
    
    DDPDanmakuShieldTypeFloat =
    DDPDanmakuShieldTypeFloatAtTo |
    DDPDanmakuShieldTypeFloatAtBottom,
};

@interface DDPPlayViewController ()<DDPMediaPlayerDelegate, DDPMessageManagerObserver, JHDanmakuEngineDelegate>
@property (strong, nonatomic) DDPPlayerControlView *controlView;
@property (strong, nonatomic) DDPPlayTopBar *topBar;
@property (strong, nonatomic) JHDanmakuEngine *danmakuEngine;
@property (strong, nonatomic) DDPMediaPlayer *player;

@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*danmakuDic;
@property (strong, nonatomic) NSTimer *autoHiddenTimer;
@property (strong, nonatomic) NSTrackingArea *trackingArea;
@property (strong, nonatomic) MASConstraint *playerViewBottomConstraint;
@property (strong, nonatomic) MASConstraint *topBarTopConstraint;
@property (assign, nonatomic) BOOL hiddenControlView;

@property (weak, nonatomic) DDPHUD *volumeHUD;
@property (assign, nonatomic) NSInteger episodeId;
@end

@implementation DDPPlayViewController {
    NSInteger _currentTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.blackColor.CGColor;
    [self.view addSubview:self.player.mediaView];
    [self.view addSubview:self.danmakuEngine.canvas];
    [self.view addSubview:self.controlView];
    [self.view addSubview:self.topBar];
    
    [self autoShowControlView];
    
    [self.player.mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.center.mas_equalTo(self.view);
        make.height.mas_lessThanOrEqualTo(self.view);
    }];

    [self.danmakuEngine.canvas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.player.mediaView);
    }];

    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        self.playerViewBottomConstraint = make.bottom.mas_equalTo(0);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(60);
        self.topBarTopConstraint = make.top.mas_equalTo(0);
    }];
    
    [self.view addTrackingArea:self.trackingArea];
    let playView = (DDPPlayView *)self.view;
    @weakify(self)
    playView.keyDownCallBack = ^(NSEvent * _Nonnull event) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        [self keyDown:event];
    };
    
    [[DDPMessageManager sharedManager] addObserver:self];
    
    
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.view.window makeFirstResponder:self.view];
    self.view.window.title = @"2333\n55555";
}

- (void)dealloc {
    [[DDPMessageManager sharedManager] removeObserver:self];
}

- (void)mouseUp:(NSEvent *)event {
    [self.view becomeFirstResponder];
    
    if (event.clickCount == 1) {
        [self performSelector:@selector(onClickPlayButton) withObject:nil afterDelay:[NSEvent doubleClickInterval]];
    }
    else if (event.clickCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onClickPlayButton) object:nil];
        [self onToggleFullScreen];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [self autoShowControlView];
}

- (void)scrollWheel:(NSEvent *)event {
    //判断是否为apple的破鼠标
    if (event.hasPreciseScrollingDeltas) {
        [self volumeValueAddBy:-event.deltaY];
    }
    else {
        [self volumeValueAddBy:event.scrollingDeltaY];
    }
}

/**
 *  相对的增加音量
 *
 *  @param addBy 增加值
 */
- (void)volumeValueAddBy:(CGFloat)addBy {
    [self.player volumeJump:addBy];
    DDPHUD *hud = self.volumeHUD;
    if (hud == nil) {
        hud = [DDPHUD loadFromNib];
        self.volumeHUD = hud;
    }
    
    hud.title = [NSString stringWithFormat:@"音量: %ld", (long)self.player.volume];
    [hud showAtView:self.view];
}

- (void)keyDown:(NSEvent *)event {
    NSString *key = event.charactersIgnoringModifiers;
    if ([key isEqualToString:@" "]) {
        [self onClickPlayButton];
    } else if ([key isEqualToString:@"\r"]) {
        [self onToggleFullScreen];
    }
}


#pragma mark - DDPMediaPlayerDelegate
- (void)mediaPlayer:(DDPMediaPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    [self.controlView updateCurrentTime:currentTime totalTime:totalTime];
}

- (void)mediaPlayer:(DDPMediaPlayer *)player statusChange:(DDPMediaPlayerStatus)status {
    
    switch (status) {
        case DDPMediaPlayerStatusPlaying:
        {
            [self.danmakuEngine start];
            self.controlView.playButton.state = NSControlStateValueOn;
        }
            break;
        case DDPMediaPlayerStatusNextEpisode:
            break;
        default:
            [self.danmakuEngine pause];
            self.controlView.playButton.state = NSControlStateValueOff;
            break;
    }
}

- (void)mediaPlayer:(DDPMediaPlayer *)player rateChange:(float)rate {
    self.danmakuEngine.systemSpeed = rate;
}

- (void)mediaPlayer:(DDPMediaPlayer *)player userJumpWithTime:(NSTimeInterval)time {
    [self.danmakuEngine setCurrentTime:time];
    if (player.isPlaying == NO) {
        [self.danmakuEngine pause];
    }
}

#pragma mark - DDPDanmakuEngineDelegate
- (NSArray <__kindof JHBaseDanmaku*>*)danmakuEngine:(JHDanmakuEngine *)danmakuEngine didSendDanmakuAtTime:(NSUInteger)time {
    if (_currentTime == time) return nil;

    _currentTime = time;

    //远端弹幕
    let tempDanmakus = self.danmakuDic[@(_currentTime)];
    return tempDanmakus;
}

- (BOOL)danmakuEngine:(JHDanmakuEngine *)danmakuEngine shouldSendDanmaku:(__kindof JHBaseDanmaku *)danmaku {
    
    //自己发的忽略屏蔽规则
    if (danmaku.sendByUserId != 0) {
        return YES;
    }
    
    DDPDanmakuShieldType danmakuShieldType = DDPDanmakuManager.shared.setting.danmakuShieldType;
    //屏蔽滚动弹幕
    if ((danmakuShieldType & DDPDanmakuShieldTypeScrollToLeft) && [danmaku isKindOfClass:[JHScrollDanmaku class]]) {
        return false;
    }
    
    if ([danmaku isKindOfClass:[JHFloatDanmaku class]]) {
        JHFloatDanmaku *_danmaku = (JHFloatDanmaku *)danmaku;
        
        if (danmakuShieldType & DDPDanmakuShieldTypeFloatAtTo && _danmaku.position == JHFloatDanmakuPositionAtTop) {
            return false;
        }
        
        if (danmakuShieldType & DDPDanmakuShieldTypeFloatAtBottom && _danmaku.position == JHFloatDanmakuPositionAtBottom) {
            return false;
        }
    }
    
    //屏蔽彩色弹幕
    if (danmakuShieldType & DDPDanmakuShieldTypeColor) {
        let color = danmaku.textColor;
        
        if ([color isEqual:[NSColor whiteColor]] || [color isEqual:[NSColor blackColor]]) {
            return true;
        }
        return false;
    }
    
    return !danmaku.filter;
}


#pragma mark - DDPSessionManagerObserver
- (void)dispatchManager:(DDPMessageManager *)manager didReceiveMessages:(nonnull NSArray<id<DDPMessageProtocol>> *)messages {
    id<DDPMessageProtocol>message = messages.firstObject;
    if ([message.messageType isEqualToString:DDPPlayerMessage.messageType]) {
        DDPPlayerMessage *aMessage = [[DDPPlayerMessage alloc] initWithObj:message];
        let danmaku = aMessage.danmaku;
        //没有弹幕 请求弹幕
        if (danmaku == nil) {
            [self requestDanmakuWithPath:aMessage.path];
        } else {
            self.danmakuDic = [DDPDanmakuManager.shared converDanmakus:danmaku filter:YES];
            self.episodeId = aMessage.episodeId;
            
            NSURL *url = [NSURL fileURLWithPath:aMessage.path];
            
            self.danmakuEngine.speed = DDPDanmakuManager.shared.setting.danmakuSpeed;
            self.danmakuEngine.canvas.alphaValue = DDPDanmakuManager.shared.setting.danmakuOpacity;
            self.danmakuEngine.limitCount = DDPDanmakuManager.shared.setting.danmakuLimitCount;
            
            if (url) {
                NSString *fileName = url.lastPathComponent;
                if (aMessage.matchName) {
                    fileName = [fileName stringByAppendingFormat:@"\n%@", aMessage.matchName];
                }
                
                self.topBar.titleLabel.stringValue = fileName;
            } else {
                self.topBar.titleLabel.stringValue = @"";
            }
            
            self.danmakuEngine.currentTime = 0;
            [self.player setMediaURL:url];
            @weakify(self)
            [self.player parseWithCompletion:^{
                @strongify(self)
                if (!self) {
                    return;
                }
                
                
                CGSize size = self.player.videoSize;
                CGFloat radio = size.width / size.height;
                [self.player.mediaView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.player.mediaView.mas_height).multipliedBy(radio);
                }];
                [self.player play];
            }];
        }
    } else if ([message.messageType isEqualToString:DDPSendDanmakuMessage.messageType]) {
        DDPSendDanmakuMessage *aMessage = [[DDPSendDanmakuMessage alloc] initWithObj:message];
        
        let danmaku = aMessage.danmaku;
        
        DDPHUD *tips = [DDPHUD loadFromNib];
        if (danmaku == nil) {
            tips.title = @"发送弹幕失败";
        } else {
            tips.title = @"发送成功";
            
            JHBaseDanmaku *sendDanmaku = [DDPDanmakuManager.shared converDanmaku:danmaku];
            sendDanmaku.sendByUserId = [[NSDate date] timeIntervalSince1970];

            NSUInteger appearTime = (NSInteger)sendDanmaku.appearTime;
            var sentDanmakus = self.danmakuDic[@(appearTime)];
            if (sentDanmakus == nil) {
                sentDanmakus = [NSMutableArray array];
                self.danmakuDic[@(appearTime)] = sentDanmakus;
            }
            [sentDanmakus addObject:sendDanmaku];
            [self.danmakuEngine sendDanmaku:sendDanmaku];
        }
        
        [tips showAtView:self.view position:DDPHUDPositionCenter];
    }
}

#pragma mark - 私有方法
- (void)requestDanmakuWithPath:(NSString *)path {
    DDPParseMessage *model = [[DDPParseMessage alloc] init];
    model.path = path;
    [[DDPMessageManager sharedManager] sendMessage:model];
}

- (void)autoShowControlView {
    
    
    void(^startHiddenTimerAction)(void) = ^{
        //显示状态 开启倒计时
        [self.autoHiddenTimer invalidate];
        self.autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(autoHideMouseControlView) userInfo:nil repeats:NO];
        self.autoHiddenTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
    };
    
    if (_hiddenControlView) {
        _hiddenControlView = NO;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.2;
            self.playerViewBottomConstraint.animator.offset(0);
            self.topBarTopConstraint.animator.offset(0);
        } completionHandler:^{
            startHiddenTimerAction();
        }];
    } else {
        startHiddenTimerAction();
    }
}

- (void)autoHideMouseControlView {
    //显示状态 隐藏
    if (_hiddenControlView == NO) {
        _hiddenControlView = YES;
        [_autoHiddenTimer invalidate];
        [NSCursor setHiddenUntilMouseMoves:YES];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.2;
            self.playerViewBottomConstraint.animator.offset(CGRectGetHeight(self.controlView.frame));
            self.topBarTopConstraint.animator.offset(-CGRectGetHeight(self.topBar.frame));
        } completionHandler:nil];
    }
}

- (void)onClickPlayButton {
    if (self.player.isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

- (void)onToggleFullScreen {
    let window = self.view.window;
    window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
    [window toggleFullScreen: nil];
}

- (void)sendDanmakuWithString:(NSString *)danmakuString {
    let message = [[DDPSendDanmakuMessage alloc] init];
    message.episodeId = self.episodeId;
    
    let danmaku = [[DDPBridgeDanmaku alloc] init];
    danmaku.time = self.danmakuEngine.currentTime + self.danmakuEngine.offsetTime;
    danmaku.mode = DDPDanmakuModeNormal;
    
    let color = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    let colorValue = (uint32_t)(color.redComponent * 256 * 256 * 255 + color.greenComponent * 256 * 255 + color.blueComponent * 255);
    
    danmaku.message = danmakuString;
    danmaku.color = colorValue;
    message.danmaku = danmaku;
    
    [[DDPMessageManager sharedManager] sendMessage:message];
}

#pragma mark - Lazy load
- (JHDanmakuEngine *)danmakuEngine {
    if (_danmakuEngine == nil) {
        _danmakuEngine = [[JHDanmakuEngine alloc] init];
        _danmakuEngine.delegate = self;
    }
    return _danmakuEngine;
}

- (DDPMediaPlayer *)player {
    if (_player == nil) {
        _player = [[DDPMediaPlayer alloc] init];
        _player.delegate = self;
    }
    return _player;
}

- (NSTrackingArea *)trackingArea {
    if(_trackingArea == nil) {
        _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.frame options:NSTrackingActiveInKeyWindow | NSTrackingMouseMoved | NSTrackingInVisibleRect owner:self userInfo:nil];
    }
    return _trackingArea;
}

- (DDPPlayTopBar *)topBar {
    if (_topBar == nil) {
        _topBar = [DDPPlayTopBar loadFromNib];
    }
    return _topBar;
}

- (DDPPlayerControlView *)controlView {
    if (_controlView == nil) {
        _controlView = [DDPPlayerControlView loadFromNib];
        @weakify(self)
        _controlView.sliderDidChangeCallBack = ^(CGFloat progress) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.player setPosition:progress completionHandler:nil];
        };
        
        _controlView.playButtonDidClickCallBack = ^(BOOL selected) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self onClickPlayButton];
        };
        
        _controlView.danmakuButtonDidClickCallBack = ^(BOOL selected) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            self.danmakuEngine.canvas.hidden = selected;
        };
        
        _controlView.sendDanmakuCallBack = ^(NSString * _Nonnull danmaku) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self sendDanmakuWithString:danmaku];
        };
        
    }
    return _controlView;
}

@end
