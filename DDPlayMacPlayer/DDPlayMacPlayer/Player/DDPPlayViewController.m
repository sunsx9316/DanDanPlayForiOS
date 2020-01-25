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
#import <Carbon/Carbon.h>
#import "DDPPlayerControlView.h"
#import "NSView+DDPTools.h"
#import "DDPMediaPlayer.h"
#import "DDPDanmakuManager.h"
#import "DDPPlayView.h"
#import "DDPPlayTopBar.h"
#import "DDPHUD.h"
#import "JHBaseDanmaku+DDPTools.h"
#import "NSColor+DDPTools.h"
#import "DDPPlayerMessage+DDPTools.h"
#import "DDPPlayerListView.h"

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


BOOL ddp_isVideoFile(NSString *aURL) {
    NSString *pathExtension = [aURL pathExtension];
    
    if ([pathExtension compare:@"mkv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return true;
    }
    
    
    CFStringRef fileExtension = (__bridge CFStringRef) [aURL pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    BOOL flag = UTTypeConformsTo(fileUTI, kUTTypeMovie);
    CFRelease(fileUTI);
    return flag;
};

//短跳转时长
static int kShortJumpValue = 5;
static int kVolumeAddingValue = 20;

@interface DDPPlayViewController ()<DDPMediaPlayerDelegate, DDPMessageManagerObserver, JHDanmakuEngineDelegate, DDPPlayerListViewDelegate>
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
@property (strong, nonatomic) NSSet *colorSet;

@property (nonatomic, weak) DDPPlayerListView *playerListView;
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
    
    [self autoShowControlViewWithCompletion:nil];
    
    [self.player.mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
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
    
    playView.didDragItemCallBack = ^(NSArray<NSString *> * _Nonnull paths) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        let items = [self addMeidaToPlayerListWithPaths:paths];
        [self.playerListView reloadData];
        [self sendParseMessageWithPath:items.firstObject.path];
    };
    
    DDPDanmakuManager.shared.settingDidChangeCallBack = ^(DDPDanmakuSettingMessage * _Nonnull setting) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        if (setting.danmakuFont) {
            let font = setting.danmakuFont;
            self.danmakuEngine.globalFont = font;
        }
        
        if (setting.danmakuSpeed) {
            self.danmakuEngine.speed = setting.danmakuSpeed.floatValue;
        }
        
        if (setting.danmakuOpacity) {
            self.danmakuEngine.canvas.alphaValue = setting.danmakuOpacity.doubleValue;
        }
        
        if (setting.danmakuEffectStyle) {
            self.danmakuEngine.globalEffectStyle = setting.danmakuEffectStyle.integerValue;
        }
        
        if (setting.danmakuOffsetTime) {
            self.danmakuEngine.offsetTime = setting.danmakuOffsetTime.doubleValue;
        }
        
        if (setting.danmakuLimitCount) {
            self.danmakuEngine.limitCount = setting.danmakuLimitCount.integerValue;
        }
        
        if (setting.playerSpeed) {
            self.player.speed = setting.playerSpeed.floatValue;
        }
    };
    
    [[DDPMessageManager sharedManager] addObserver:self];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.view.window makeFirstResponder:self.view];
}

- (void)dealloc {
    [[DDPMessageManager sharedManager] removeObserver:self];
}

- (void)mouseUp:(NSEvent *)event {
    
    let position = event.locationInWindow;
    if (CGRectContainsPoint(self.topBar.frame, position) || CGRectContainsPoint(self.controlView.frame, position)) {
        return;
    }
    
    
    if (event.clickCount == 1) {
        if (self.playerListView) {
            [self hidePlayerList];
            return;
        }
        
        [self performSelector:@selector(onClickPlayButton) withObject:nil afterDelay:[NSEvent doubleClickInterval]];
    }
    else if (event.clickCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onClickPlayButton) object:nil];
        [self onToggleFullScreen];
        [self hidePlayerList];
    }
    
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [self autoShowControlViewWithCompletion:^{
        let position = theEvent.locationInWindow;
        if (CGRectContainsPoint(self.topBar.frame, position) || CGRectContainsPoint(self.controlView.frame, position)) {
            [self.autoHiddenTimer invalidate];
        }
    }];
}

- (void)mouseExited:(NSEvent *)event {
    [self mouseMoved:event];
}


- (void)scrollWheel:(NSEvent *)event {
    //判断是否为apple的破鼠标
    if (event.hasPreciseScrollingDeltas) {
        //不响应手离开鼠标的事件
        if (event.momentumPhase == NSEventPhaseNone) {
            //让步长为2的倍数
            var deltaY = (NSInteger)event.deltaY;
            var absDeltaY = labs(deltaY);
            if (absDeltaY != 0) {
                let remainder = absDeltaY % 2;
                if (remainder == 1) {
                    absDeltaY = absDeltaY - remainder;
                }
            }
            
            deltaY = deltaY > 0 ? -absDeltaY : absDeltaY;
            if (event.directionInvertedFromDevice == NO) {
                deltaY *= -1;
            }
            [self volumeValueAddBy:deltaY];
        }
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
        hud = [[DDPHUD alloc] initWithStyle:DDPHUDStyleNormal];
        self.volumeHUD = hud;
    }
    
    hud.title = [NSString stringWithFormat:@"音量: %ld", (long)self.player.volume];
    [hud showAtView:self.view];
}

- (void)keyDown:(NSEvent *)event {
    let keyCode = event.keyCode;
    
    @weakify(self)
    switch (keyCode) {
        case kVK_Tab: {
            [self.controlView.inputTextField becomeFirstResponder];
            [self autoShowControlViewWithCompletion:^{
                [self.autoHiddenTimer invalidate];
            }];
        }
            break;
        case kVK_Space:
            [self onClickPlayButton];
            break;
        case kVK_Return:
            [self onToggleFullScreen];
            break;
        case kVK_LeftArrow:
        case kVK_RightArrow: {
            let jumpTime = keyCode == kVK_LeftArrow ? -kShortJumpValue : kShortJumpValue;
            [self.player jump: jumpTime completionHandler:^(NSTimeInterval time) {
                @strongify(self)
                if (!self) {
                    return;
                }
                
                self.danmakuEngine.currentTime = time;
            }];
        }
            break;
        case kVK_UpArrow:
        case kVK_DownArrow: {
            let volumeValue = keyCode == kVK_DownArrow ? -kVolumeAddingValue : kVolumeAddingValue;
            [self volumeValueAddBy:volumeValue];
        }
            break;
        default:
            break;
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
        case DDPMediaPlayerStatusNextEpisode: {
            let currentPlayItem = player.currentPlayItem;
            let index = [player indexWithItem:currentPlayItem];
            if (index != NSNotFound) {
                var nextIndex = index + 1;
                if (nextIndex >= player.playerLists.count) {
                    nextIndex = 0;
                }
                
                let nextPlayItem = player.playerLists[nextIndex];
                [self requestDanmakuWithPath:nextPlayItem.path];
            }
        }
            break;
        case DDPMediaPlayerStatusPause: {
            [self.danmakuEngine pause];
            self.controlView.playButton.state = NSControlStateValueOff;
        }
            break;
        case DDPMediaPlayerStatusStop: {
            [player stop];
            self.controlView.playButton.state = NSControlStateValueOff;
        }
            break;
        case DDPMediaPlayerStatusUnknow:
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
        let attStr = danmaku.attributedString;
        if (attStr) {
            let mAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
            [mAttStr addAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName : NSColor.greenColor} range:NSMakeRange(0, mAttStr.length)];
            danmaku.attributedString = mAttStr;
        }
        return YES;
    }
    
    DDPDanmakuShieldType danmakuShieldType = (DDPDanmakuShieldType)DDPDanmakuManager.shared.setting.danmakuShieldType.integerValue;
    
    if (danmakuShieldType == DDPDanmakuShieldTypeNone) {
        return YES;
    }
    
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
        if ([self.colorSet containsObject:color]) {
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
        let danmakus = aMessage.danmaku;
        //没有弹幕 请求弹幕
        if (danmakus == nil) {
            [self requestDanmakuWithPath:aMessage.path];
        } else {
            self.danmakuDic = [DDPDanmakuManager.shared converDanmakus:danmakus filter:YES];
            self.episodeId = aMessage.episodeId;
            
            NSURL *url = [NSURL fileURLWithPath:aMessage.path];
            
//            let setting = DDPDanmakuManager.shared.setting;
//
//            self.danmakuEngine.speed = setting.danmakuSpeed.doubleValue;
//            self.danmakuEngine.canvas.alphaValue = setting.danmakuOpacity.doubleValue;
//            self.danmakuEngine.limitCount = setting.danmakuLimitCount.integerValue;
            
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
            [self.player playWithItem:aMessage];
            
            //vlc神奇的bug...
            let frame = self.view.window.frame;
            [self.view.window setFrame:CGRectInset(frame, 1, 1) display:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.view.window setFrame:frame display:YES];
            });
        }
    } else if ([message.messageType isEqualToString:DDPSendDanmakuMessage.messageType]) {
        DDPSendDanmakuMessage *aMessage = [[DDPSendDanmakuMessage alloc] initWithObj:message];
        
        let danmaku = aMessage.danmaku;
        
        DDPHUD *tips = [[DDPHUD alloc] initWithStyle:DDPHUDStyleNormal];
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
    } else if ([message.messageType isEqualToString:DDPPlayerListMessage.messageType]) {
        let aMessage = [[DDPPlayerListMessage alloc] initWithObj:message];
        
        let items = [self addMeidaToPlayerListWithPaths:aMessage.paths];
        if (self.player.isPlaying == NO) {
            [self sendParseMessageWithPath:items.firstObject.path];
        }
    }  else if ([message.messageType isEqualToString:DDPLoalLocalDanmakuMessage.messageType]) {
        if (self.player.currentPlayItem) {
            DDPLoalLocalDanmakuMessage *msg = [[DDPLoalLocalDanmakuMessage alloc] initWithObj:message];
            self.danmakuDic = [DDPDanmakuManager.shared converDanmakus:msg.danmaku filter:YES];
        }
    }
}

#pragma mark - DDPPlayerListViewDelegate
- (NSInteger)numberOfRowAtPlayerListView:(DDPPlayerListView *)view {
    return self.player.playerLists.count;
}

- (NSString *)playerListView:(DDPPlayerListView *)view titleAtRow:(NSInteger)row {
    let item = self.player.playerLists[row];
    return item.path;
}

- (void)playerListView:(DDPPlayerListView *)view didSelectedRow:(NSInteger)row {
    let item = self.player.playerLists[row];
    [self sendParseMessageWithPath:item.path];
}

- (void)playerListView:(DDPPlayerListView *)view didDeleteWithIndexSet:(NSIndexSet *)indexSet {
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.player removeMediaAtIndex:idx];
    }];
}

- (NSInteger)currentPlayIndexAtPlayerListView:(DDPPlayerListView *)view {
    return [self.player indexWithItem:self.player.currentPlayItem];
}

- (void)mediaPlayer:(DDPMediaPlayer *)player mediaDidChange:(id<DDPMediaItemProtocol>)media {
    [self.playerListView reloadData];
}

#pragma mark - 私有方法
- (void)requestDanmakuWithPath:(NSString *)path {
    DDPParseMessage *model = [[DDPParseMessage alloc] init];
    model.path = path;
    [[DDPMessageManager sharedManager] sendMessage:model];
}

- (void)autoShowControlViewWithCompletion:(void(^)(void))completion {
    void(^startHiddenTimerAction)(void) = ^{
        //显示状态 开启倒计时
        [self.autoHiddenTimer invalidate];
        self.autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(autoHideMouseControlView) userInfo:nil repeats:NO];
        self.autoHiddenTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
        
        if (completion) {
            completion();
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (self.hiddenControlView) {
            self.hiddenControlView = NO;
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                context.duration = 0.2;
                self.playerViewBottomConstraint.animator.offset(0);
                self.topBarTopConstraint.animator.offset(0);
                self.controlView.animator.topProgressAlpha = 0;
            } completionHandler:^{
                startHiddenTimerAction();
            }];
        } else {
            startHiddenTimerAction();
        }
    });
    
}

- (void)autoHideMouseControlView {
    dispatch_async(dispatch_get_main_queue(), ^{
        //显示状态 隐藏
        if (self.hiddenControlView == NO) {
            self.hiddenControlView = YES;
            [self.autoHiddenTimer invalidate];
            [NSCursor setHiddenUntilMouseMoves:YES];
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                context.duration = 0.2;
                self.playerViewBottomConstraint.animator.offset(CGRectGetHeight(self.controlView.frame));
                self.topBarTopConstraint.animator.offset(-CGRectGetHeight(self.topBar.frame));
                self.controlView.animator.topProgressAlpha = 1;
            } completionHandler:nil];
        }
    });
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
    danmaku.mode = self.controlView.sendanmakuStyle;
    danmaku.message = danmakuString;
    danmaku.color = self.controlView.sendanmakuColor;
    message.danmaku = danmaku;
    
    [[DDPMessageManager sharedManager] sendMessage:message];
}

- (void)sendParseMessageWithPath:(NSString *)path {
    DDPParseMessage *message = [[DDPParseMessage alloc] init];
    message.path = path;
    [[DDPMessageManager sharedManager] sendMessage:message];
}

- (NSArray <DDPPlayerMessage *>*)addMeidaToPlayerListWithPaths:(NSArray <NSString *>*)paths {
    NSMutableArray <DDPPlayerMessage *>*arr = [NSMutableArray arrayWithCapacity:paths.count];
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = [NSURL fileURLWithPath:obj];
        
        if (url.hasDirectoryPath) {
            var contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
            //排序文件名
            contents = [contents sortedArrayUsingComparator:^NSComparisonResult(NSURL * _Nonnull obj1, NSURL * _Nonnull obj2) {
                return [obj1.absoluteString compare:obj2.absoluteString];
            }];
            
            [contents enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                if (obj1.isFileURL && ddp_isVideoFile(obj1.path)) {
                    DDPPlayerMessage *m = [[DDPPlayerMessage alloc] init];
                    m.path = obj1.path;
                    [arr addObject:m];
                }
            }];
        } else {
            DDPPlayerMessage *m = [[DDPPlayerMessage alloc] init];
            m.path = obj;
            [arr addObject:m];
        }
        
    }];
    
    [self.player addMediaItems:arr];
    return arr;
}

- (void)showPlayerList {
    var view = self.playerListView;
    
    if (!view) {
        view = [DDPPlayerListView loadFromNib];
        self.playerListView = view;
        view.delegate = self;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(0);
            make.bottom.equalTo(self.controlView.mas_top);
            make.top.equalTo(self.topBar.mas_bottom);
            make.width.mas_greaterThanOrEqualTo(250);
            make.width.equalTo(self.view).multipliedBy(0.2);
        }];
    }
}

- (void)hidePlayerList {
    [self.playerListView removeFromSuperview];
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
        _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.frame options:NSTrackingActiveInKeyWindow | NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
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
        
        _controlView.onClickPlayListButtonCallBack = ^{
            @strongify(self)
            if (!self) {
                return;
            }
            
            var view = self.playerListView;
            if (view) {
                [self hidePlayerList];
            } else {
                [self showPlayerList];
            }
        };
        
        _controlView.onClickPlayNextButtonCallBack = ^{
            @strongify(self)
            if (!self) {
                return;
            }
            
            let item = [self.player nextItem];
            if (item) {
                [self sendParseMessageWithPath:item.path];
            }
        };
    }
    return _controlView;
}

- (NSSet *)colorSet {
    if (_colorSet == nil) {
        let whiletColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
        let blackColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        _colorSet = [NSSet setWithArray:@[whiletColor, blackColor]];
    }
    return _colorSet;
}

@end
