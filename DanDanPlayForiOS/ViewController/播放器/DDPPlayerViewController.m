//
//  DDPPlayerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/21.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerViewController.h"
#import "DDPMatchViewController.h"
#import "DDPLocalFileManagerPickerViewController.h"
#import "DDPSMBFileManagerPickerViewController.h"
#import "DDPPlayerSendDanmakuViewController.h"
#import "DDPDanmakuFilterViewController.h"
#import "DDPSettingViewController.h"

#import "DDPPlayerInterfaceView.h"
#import "DDPMediaPlayer.h"
#import "JHDanmakuRender.h"
#import "DDPDanmakuManager.h"
#import "DDPPlayerSendDanmakuConfigView.h"
#import "DDPPlayerNoticeView.h"

#import "DDPSMBVideoModel.h"
#import "NSString+Tools.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSURL+Tools.h"
#import "DDPBaseDanmaku+Tools.h"
#import "DDPVolumeView.h"
#import <AVFoundation/AVFoundation.h>
#import "DDPVideoModel+Tools.h"
#import <JHDanmakuContainer.h>
#import "YYThreadSafeDictionary.h"
#import "DDPBaseNavigationController.h"
#import "DDPLoginViewController.h"
#import "DDPDanmakuProducer.h"

//在主线程分析弹幕的时间
#define PARSE_TIME 10

@interface DDPPlayerViewController ()<DDPMediaPlayerDelegate, JHDanmakuEngineDelegate, DDPPlayerConfigPanelViewControllerDelegate, DDPPlayerInterfaceViewDelegate, DDPCacheManagerDelagate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) DDPPlayerInterfaceView *interfaceView;
@property (strong, nonatomic) DDPMediaPlayer *player;
@property (strong, nonatomic) JHDanmakuEngine *danmakuEngine;

@property (strong, nonatomic) DDPDanmakuProducer *danmakuProducer;
//已发送的弹幕
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSMutableArray<JHBaseDanmaku *>*>*sentDanmakuDic;
//当前弹幕屏蔽标志 因为可以实时修改屏蔽的弹幕 所以需要设置唯一的标志
//@property (assign, atomic) NSInteger danmakuParseFlag;
@end

@implementation DDPPlayerViewController
{
    NSInteger _currentTime;
    
    NSOperationQueue *_queue;
    NSLock *_lock;
    //kvo监听的属性
    NSArray <NSString *>*_addKeyPaths;
    //播放器是否正在播放
    BOOL _isPlay;
    //进入后台时保存当前播放器时间
    NSInteger _cacheCurrentTime;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIViewController attemptRotationToDeviceOrientation];
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.player.isPlaying == NO) {
        [self.player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.player.isPlaying) {
        [self.player pause];
    }
}

- (BOOL)prefersStatusBarHidden {
    if (self.viewIfLoaded == false) {
        return false;
    }
    return !self.interfaceView.isShow;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [DDPCacheManager shareCacheManager].playInterfaceOrientation;
}

//x自动隐藏底下的指示条
- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.viewIfLoaded == false) {
        return false;
    }
    return !self.interfaceView.isShow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.ddp_navigationBarHidden = true;
//    self.ddp_fullScreenPopGestureEnabled = false;
    self.view.backgroundColor = [UIColor blackColor];
    
    _lock = [[NSLock alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _currentTime = -1;
//    self.danmakuParseFlag = [NSDate date].hash;
    
    [self.view addSubview:self.player.mediaView];
    [self.view insertSubview:self.danmakuEngine.canvas aboveSubview:self.player.mediaView];
    [self.view addSubview:self.interfaceView];
    
    [self.danmakuEngine.canvas mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([DDPCacheManager shareCacheManager].subtitleProtectArea) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.mas_offset(-DDP_HEIGHT * 0.12);
        }
        else {
            make.edges.mas_equalTo(0);
        }
    }];
    
    [self.player.mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.interfaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    //添加一堆监听
    [self addNotice];
    
    //刷新
    [self reload];
}

- (void)dealloc {
    //保存上次播放时间
    [[DDPCacheManager shareCacheManager] saveLastPlayTime:self.player.currentTime videoModel:_model];
    
    self.player.speed = 1.0;
    [self.player stop];
    [self.danmakuEngine stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_addKeyPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:obj];
    }];
    
    _lock = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuFont)]) {
        UIFont *font = change[NSKeyValueChangeNewKey];
        self.danmakuEngine.globalFont = font;
    }
    else if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuSpeed)]) {
        float speed = [change[NSKeyValueChangeNewKey] floatValue];
        [self.danmakuEngine setUserInfoWithKey:JHScrollDanmakuExtraSpeedKey value:@(speed)];
        LOG_DEBUG(DDPLogModulePlayer, @"设置弹幕速度 %f", speed);
    }
    else if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuEffectStyle)]) {
        JHDanmakuEffectStyle style = [change[NSKeyValueChangeNewKey] integerValue];
        self.danmakuEngine.globalEffectStyle = style;
    }
    else if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuOpacity)]) {
        self.danmakuEngine.canvas.alpha = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuLimitCount)]) {
        self.danmakuEngine.limitCount = [change[NSKeyValueChangeNewKey] integerValue];
    }
    else if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], subtitleProtectArea)]) {
        BOOL value = [change[NSKeyValueChangeNewKey] boolValue];
        
        [self.danmakuEngine.canvas mas_updateConstraints:^(MASConstraintMaker *make) {
            if (value) {
                make.bottom.mas_offset(-DDP_HEIGHT * 0.12);
            }
            else {
                make.bottom.mas_equalTo(0);
            }
        }];
    }
}

- (void)setModel:(DDPVideoModel *)model {
    DDPVideoModel *oldVideoModel = _model;
    //保存上次播放时间
    _model = model;
    [DDPCacheManager shareCacheManager].currentPlayVideoModel = _model;
    
    if (self.viewIfLoaded) {
        [[DDPCacheManager shareCacheManager] saveLastPlayTime:self.player.currentTime videoModel:oldVideoModel];
        
        [self reload];
        [self.player play];
    }
}

#pragma mark - DDPMediaPlayerDelegate
- (void)mediaPlayer:(DDPMediaPlayer *)player progress:(float)progress currentTime:(NSString *)currentTime totalTime:(NSString *)totalTime {
    [self.interfaceView updateCurrentTime:currentTime totalTime:totalTime progress:progress];
}

- (void)mediaPlayer:(DDPMediaPlayer *)player statusChange:(DDPMediaPlayerStatus)status {
//    [self.interfaceView updateWithPlayerStatus:status];
    
    switch (status) {
        case DDPMediaPlayerStatusPlaying:
        {
            [self.danmakuEngine start];
        }
            break;
        case DDPMediaPlayerStatusNextEpisode:
        {
            
            DDPPlayerPlayMode mode = [DDPCacheManager shareCacheManager].playMode;
            //单集循环
            if (mode == DDPPlayerPlayModeSingleCircle) {
                self.model = self.model;
            }
            //列表循环
            else if (mode == DDPPlayerPlayModeCircle) {
                DDPFile *currentFile = self.model.file;
                DDPFile *parentFile = currentFile.parentFile;
                NSInteger index = [parentFile.subFiles indexOfObject:currentFile];
                
                if (index != NSNotFound) {
                    NSInteger count = parentFile.subFiles.count;
                    //找到下一个是视频的模型
                    for (NSInteger i = 0; i < count; ++i) {
                        currentFile = parentFile.subFiles[(i + 1 + index) % count];
                        if (currentFile.type == DDPFileTypeDocument && ddp_isVideoFile(currentFile.fileURL.absoluteString)) {
                            [self playerConfigPanelViewController:nil didSelectedModel:currentFile.videoModel];
                            return;
                        }
                    }
                }
            }
            else if (mode == DDPPlayerPlayModeOrder) {
                DDPFile *currentFile = self.model.file;
                DDPFile *parentFile = currentFile.parentFile;
                NSInteger index = [parentFile.subFiles indexOfObject:currentFile];
                if (index != NSNotFound) {
                    NSInteger count = parentFile.subFiles.count;
                    //找到下一个是视频的模型
                    for (NSInteger i = index + 1; i < count; ++i) {
                        currentFile = parentFile.subFiles[i];
                        NSString *path = currentFile.fileURL.absoluteString;
                        if (currentFile.type == DDPFileTypeDocument && (ddp_isVideoFile(path) || [path hasPrefix:@"http"])) {
                            [self playerConfigPanelViewController:nil didSelectedModel:currentFile.videoModel];
                            return;
                        }
                    }
                }
            }
        }
            break;
        default:
            [self.danmakuEngine pause];
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
- (NSArray<id<JHDanmakuProtocol>> *)danmakuEngine:(JHDanmakuEngine *)danmakuEngine didSendDanmakuAtTime:(NSUInteger)time {
    if (_currentTime == time) return nil;
    
    _currentTime = time;
    
    //远端弹幕
    let tempDanmakus = [self.danmakuProducer damakusAtTime:_currentTime];
    
    //已发送的弹幕
    let sentDanmakus = self.sentDanmakuDic[@(_currentTime)];
    if (sentDanmakus) {
        return [sentDanmakus arrayByAddingObjectsFromArray:tempDanmakus];
    }
    return tempDanmakus;
}

- (BOOL)danmakuEngine:(JHDanmakuEngine *)danmakuEngine shouldSendDanmaku:(JHBaseDanmaku *)danmaku {
    
    //自己发的忽略屏蔽规则
    if (danmaku.sendByUserId != 0) {
        let attStr = danmaku.attributedString;
        if (attStr) {
            let mAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
            [mAttStr addAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName : UIColor.greenColor} range:NSMakeRange(0, mAttStr.length)];
            danmaku.attributedString = mAttStr;
        }
        
        return YES;
    }
    
    DDPDanmakuShieldType danmakuShieldType = [DDPCacheManager shareCacheManager].danmakuShieldType;
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
        UIColor *color = nil;
        if (danmaku.attributedString.length) {
            color = [danmaku.attributedString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
            let r = color.red;
            let g = color.green;
            let b = color.blue;
            BOOL isWhite = r == 1 && g == 1 && b == 1;
            BOOL isBlack = r == 0 && g == 0 && b == 0;
            if (isWhite || isBlack) {
                return true;
            }
        }
        
        return false;
    }
    
    return !danmaku.filter;
}

//- (void)danmakuEngine:(JHDanmakuEngine *)danmakuEngine configContent:(JHDanmakuContainer *)container {
//    JHBaseDanmaku *danmaku = container.danmaku;
//    if (danmaku.sendByUserId != 0) {
//        //添加下划线
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:container.attributedText];
//        [str addAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName : [UIColor greenColor]} range:NSMakeRange(0, str.length)];
//        container.attributedText = str;
//    }
//}

#pragma mark - DDPPlayerInterfaceViewDelegate
- (void)interfaceViewDidTouchSendDanmakuButton {
    
    if ([self showLoginAlertWithAction:^{
        
        DDPLoginViewController *vc = [[DDPLoginViewController alloc] init];
        DDPBaseNavigationController *nav = [[DDPBaseNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:true completion:nil];
        
    }] == false) {
        return;
    }

    
    DDPPlayerSendDanmakuViewController *vc = [[DDPPlayerSendDanmakuViewController alloc] init];
    @weakify(self)
    vc.sendDanmakuCallBack = ^(UIColor *color, DDPDanmakuMode mode, NSString *text) {
        @strongify(self)
        if (!self) return;
        
        if (text.length) {
            NSUInteger episodeId = self.model.identity;
            if (episodeId == 0) {
                episodeId = self.model.relevanceEpisodeId;
            }
            
            if (episodeId == 0) return;
            
            
            DDPDanmaku *danmaku = [[DDPDanmaku alloc] init];
            
            danmaku.color = ddp_danmakuColor(color);
            danmaku.time = self.danmakuEngine.currentTime + self.danmakuEngine.offsetTime;
            danmaku.mode = mode;
            danmaku.message = text;
            //隐藏UI
            [self.interfaceView dismissWithAnimate:YES];
            //发射弹幕
            [DDPCommentNetManagerOperation launchDanmakuWithModel:danmaku episodeId:episodeId completionHandler:^(NSError *error) {
                if (error) {
                    [self.view showWithText:@"发送失败"];
                }
                else {
                    [self.view showWithText:@"发送成功"];
                    JHBaseDanmaku *sendDanmaku = [DDPDanmakuManager converDanmaku:danmaku];
                    sendDanmaku.sendByUserId = [[NSDate date] timeIntervalSince1970];
                    
                    NSUInteger appearTime = (NSInteger)sendDanmaku.appearTime;
                    var sentDanmakus = self.sentDanmakuDic[@(appearTime)];
                    if (sentDanmakus == nil) {
                        sentDanmakus = [NSMutableArray array];
                        self.sentDanmakuDic[@(appearTime)] = sentDanmakus;
                    }
                    [sentDanmakus addObject:sendDanmaku];
                    [self.danmakuEngine sendDanmaku:sendDanmaku];
                    
                    //发送成功 缓存弹幕
                    NSMutableArray <DDPDanmaku *>*danmakus = [DDPDanmakuManager danmakuCacheWithEpisodeId:episodeId source:DDPDanmakuTypeByUser].mutableCopy;
                    [danmakus addObject:danmaku];
                    
                    [DDPDanmakuManager saveDanmakuWithObj:danmakus episodeId:episodeId source:DDPDanmakuTypeByUser];
                    
                }
            }];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)interfaceView:(DDPPlayerInterfaceView *)view touchSliderWithTime:(int)time {
    [self.danmakuProducer reloadDataWithTime:time];
}

- (void)interfaceView:(DDPPlayerInterfaceView *)view touchDanmakuVisiableButton:(BOOL)visiable {
    self.danmakuEngine.canvas.hidden = !visiable;
}

- (void)interfaceViewDidTapSubTitleIndexEmptyView {
    @weakify(self)
    [self pickFileWithType:PickerFileTypeSubtitle selectedFileCallBack:^(__kindof DDPFile *aFile) {
        @strongify(self)
        if (!self) return;
        
        if ([aFile isKindOfClass:[DDPSMBFile class]]) {
#if !DDPAPPTYPE
            [self downloadSubtitleFile:aFile];
#endif
        }
        else {
            [self.player openVideoSubTitlesFromFile:aFile.fileURL];
        }
    }];
}

- (void)interfaceViewDidTouchCustomMatchButton {
    [self playerConfigPanelViewControllerDidTouchMatchCell];
}

#pragma mark - DDPPlayerConfigPanelViewControllerDelegate
- (void)playerConfigPanelViewController:(DDPPlayerConfigPanelViewController *)viewController didSelectedModel:(DDPVideoModel *)model {
    //smb文件 获取文件hash值之后再匹配弹幕
    if ([model isKindOfClass:[DDPSMBVideoModel class]]) {
        DDPSMBVideoModel *aVideoModel = (DDPSMBVideoModel *)model;
        DDPSMBFile *file = aVideoModel.file;
        
        if (ddp_isVideoFile(file.fileURL.absoluteString)) {
            void(^matchVideoAction)(NSString *) = ^(NSString *path) {
                NSString *hash = [[[NSFileHandle fileHandleForReadingAtPath:path] readDataOfLength: MEDIA_MATCH_LENGTH] md5String];
                [[DDPCacheManager shareCacheManager] saveSMBFileHashWithHash:hash file:file.sessionFile];
                DDPSMBVideoModel *model = [[DDPSMBVideoModel alloc] initWithFileURL:file.sessionFile.fullURL hash:hash length:(NSUInteger)file.sessionFile.fileSize];
                model.file = file;
                [self matchVideoWithModel:model];
            };
            
            //查找是否获取过文件hash
            NSString *hash = [[DDPCacheManager shareCacheManager] SMBFileHash:file.sessionFile];
            if (hash.length) {
                DDPSMBVideoModel *model = [[DDPSMBVideoModel alloc] initWithFileURL:file.sessionFile.fullURL hash:hash length:(NSUInteger)file.sessionFile.fileSize];
                model.file = file;
                
                [self matchVideoWithModel:model];
            }
            else {
                MBProgressHUD *_aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
                _aHUD.label.text = @"分析视频中...";
                
                [[DDPToolsManager shareToolsManager] downloadSMBFile:file progress:^(uint64_t totalBytesReceived, int64_t totalBytesExpectedToReceive, TOSMBSessionDownloadTask *downloadTask) {
                    _aHUD.progress = totalBytesReceived * 1.0 / MIN(totalBytesExpectedToReceive, MEDIA_MATCH_LENGTH);
                    if (totalBytesReceived >= MEDIA_MATCH_LENGTH) {
                        [downloadTask cancel];
                    }
                } cancel:^(NSString *cachePath) {
                    [_aHUD hideAnimated:YES];
                    matchVideoAction(cachePath);
                } completion:^(NSString *destinationFilePath, NSError *error) {
                    [_aHUD hideAnimated:YES];
                    
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        matchVideoAction(destinationFilePath);
                    }
                }];
            }
        }
    }
    else {
        [self matchVideoWithModel:model];
    }
    
    [self.interfaceView dismissWithAnimate:true];
}

- (void)playerConfigPanelViewController:(DDPPlayerConfigPanelViewController *)viewController didTouchStepper:(CGFloat)value {
    self.danmakuEngine.offsetTime = value;
}

- (void)playerConfigPanelViewControllerDidTouchSelectedDanmakuCell {
#if !DDPAPPTYPE
    @weakify(self)
    [self pickFileWithType:PickerFileTypeDanmaku selectedFileCallBack:^(__kindof DDPFile *aFile) {
        @strongify(self)
        if (!self) return;
        
        if ([aFile isKindOfClass:[DDPSMBFile class]]) {
            [self downloadDanmakuFile:aFile];
        }
        else {
            [self openDanmakuWithURL:aFile.fileURL];
        }
    }];
#endif
}

- (void)playerConfigPanelViewControllerDidTouchMatchCell {
#if !DDPAPPTYPE
    DDPMatchViewController *vc = [[DDPMatchViewController alloc] init];
    vc.model = self.model;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
#endif
}

- (void)playerConfigPanelViewControllerDidTouchFilterCell {
    DDPDanmakuFilterViewController *vc = [[DDPDanmakuFilterViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    vc.updateFilterCallBack = ^{
        @strongify(self)
        if (!self) return;
        
        [self.danmakuProducer reloadDataWithTime:(NSInteger)self.player.currentTime];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)playerConfigPanelViewControllerDidTouchOtherSettingCell {
    DDPSettingViewController *vc = [[DDPSettingViewController alloc] init];
    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 私有方法
- (void)reload {
    //转换弹幕
    NSDictionary *dic = [DDPDanmakuManager converDanmakus:_model.danmakus.collection filter:NO];
    _sentDanmakuDic = [NSMutableDictionary dictionary];
    self.danmakuProducer = [[DDPDanmakuProducer alloc] initWithDamakus:dic];
    [self.danmakuProducer reloadDataWithTime:0];
    //更换视频
    self.player.media = _model;
    self.danmakuEngine.currentTime = 0;
    
    self.interfaceView.model = _model;
    
#if !DDPAPPTYPE
    DDPSMBFile *file = _model.file;
    DDPSMBFile *parentFile = file.parentFile;
    //自动下载远程视频字幕
    if ([DDPCacheManager shareCacheManager].openAutoDownloadSubtitle && [_model isKindOfClass:[DDPSMBVideoModel class]]) {
        NSString *videoPath = file.sessionFile.filePath;
        [parentFile.subFiles enumerateObjectsUsingBlock:^(DDPSMBFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = obj.sessionFile.filePath;
            if ([path isSubtileFileWithVideoPath:videoPath]) {
                *stop = YES;
                [self downloadSubtitleFile:obj];
            }
        }];
    }
    
    //弹幕
    if ([_model isKindOfClass:[DDPSMBVideoModel class]]) {
        NSString *videoPath = file.sessionFile.filePath;
        [parentFile.subFiles enumerateObjectsUsingBlock:^(DDPSMBFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.sessionFile.filePath isDanmakuFileWithVideoPath:videoPath]) {
                *stop = YES;
                [self downloadDanmakuFile:obj];
            }
        }];
    }
    else {
        //加载同名弹幕文件
        if ([DDPCacheManager shareCacheManager].loadLocalDanmaku) {
            NSArray *subtitles = [DDPToolsManager subTitleFileWithLocalURL:file.fileURL];
            if (subtitles.count) {
                [self openDanmakuWithURL:subtitles.firstObject];
            }            
        }
    }
#endif
    //添加播放记录
    [DDPFavoriteNetManagerOperation addHistoryWithEpisodeIds:@[@(_model.identity)] addToFavorite:YES completionHandler:^(NSError *error) {
        if (error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATTENTION_SUCCESS_NOTICE object:@(self.model.identity) userInfo:@{ATTENTION_KEY : @(YES)}];
        }
    }];
}

#if !DDPAPPTYPE
/**
 下载字幕文件
 
 @param file 字幕文件
 */
- (void)downloadSubtitleFile:(DDPSMBFile *)file {
    NSString *downloadPath = ddp_subtitleDownloadPath();
    NSString *cachePath = [downloadPath stringByAppendingPathComponent:file.name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [self.player openVideoSubTitlesFromFile:[NSURL fileURLWithPath:cachePath]];
    }
    else {
        [[DDPToolsManager shareToolsManager] downloadSMBFile:file destinationPath:downloadPath progress:nil cancel:nil completion:^(NSString *destinationFilePath, NSError *error) {
            [self.player openVideoSubTitlesFromFile:[NSURL fileURLWithPath:destinationFilePath]];
        }];
    }
}


/**
 下载弹幕
 
 @param file 弹幕文件
 */
- (void)downloadDanmakuFile:(DDPSMBFile *)file {
    NSString *downloadPath = ddp_danmakuDownloadPath();
    NSString *cachePath = [downloadPath stringByAppendingPathComponent:file.name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [self openDanmakuWithURL:[NSURL fileURLWithPath:cachePath]];
    }
    else {
        [[DDPToolsManager shareToolsManager] downloadSMBFile:file destinationPath:downloadPath progress:nil cancel:nil completion:^(NSString *destinationFilePath, NSError *error) {
            if (error) {
                [self.view showWithError:error];
            }
            else {
                [self openDanmakuWithURL:[NSURL fileURLWithPath:destinationFilePath]];
            }
        }];
    }
}
#endif

/**
 尝试打开本地弹幕文件
 
 @param url 路径
 */
- (void)openDanmakuWithURL:(NSURL *)url {
    NSError *err;
    NSData *danmaku = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&err];
    if (err) {
        [self.view showWithText:@"弹幕读取出错!"];
    }
    else {
//        [self.danmakuDictionary removeAllObjects];
        NSDictionary *dic = [DDPDanmakuManager parseLocalDanmakuWithSource:DDPDanmakuTypeBiliBili obj:danmaku];
//        [self.danmakuDictionary addEntriesFromDictionary:dic];
        self.danmakuEngine.currentTime = self.player.currentTime;
        
        self.danmakuProducer = [[DDPDanmakuProducer alloc] initWithDamakus:dic];
        [self.danmakuProducer reloadDataWithTime:self.danmakuEngine.currentTime];
        
        __block NSUInteger danmakuCount = 0;
        [dic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSMutableArray<JHBaseDanmaku *> * _Nonnull obj, BOOL * _Nonnull stop) {
            danmakuCount += obj.count;
        }];
        [self.view showWithText:[NSString stringWithFormat:@"加载弹幕成功 共%lu条", (unsigned long)danmakuCount]];
    }
}

/**
 查找视频弹幕
 
 @param model 视频模型
 */
- (void)matchVideoWithModel:(DDPVideoModel *)model {
#if !DDPAPPTYPE
    
    @weakify(self)
    [DDPMethod matchVideoModel:model useDefaultMode:NO completion:^(DDPDanmakuCollection *collection, NSError *error) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        if (error != nil) {
            DDPMatchViewController *vc = [[DDPMatchViewController alloc] init];
            vc.model = model;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            [self.interfaceView dismissWithAnimate:YES];
            self.model = model;
        }
    }];
#endif
}

- (void)configLeftItem {
    
}

- (void)pickFileWithType:(PickerFileType)type
    selectedFileCallBack:(SelectedFileAction)selectedFileCallBack {
    DDPFile *file = self.model.file;
    if ([file isKindOfClass:[DDPSMBFile class]]) {
        
#if !DDPAPPTYPE
        NSMutableArray *vcArr = [NSMutableArray array];
        DDPSMBFile *tempFile = file.parentFile;
        do {
            DDPSMBFileManagerPickerViewController *vc = [[DDPSMBFileManagerPickerViewController alloc] init];
            vc.fileType = type;
            vc.selectedFileCallBack = selectedFileCallBack;
            
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:tempFile.subFiles];
            [tempArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DDPSMBFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type == DDPFileTypeDocument) {
                    if ((type & PickerFileTypeDanmaku) && ddp_isDanmakuFile(obj.fileURL.absoluteString) == NO) {
                        [tempArr removeObject:obj];
                    }
                    else if ((type & PickerFileTypeSubtitle) && ddp_isSubTitleFile(obj.fileURL.absoluteString) == NO) {
                        [tempArr removeObject:obj];
                    }
                }
            }];
            
            DDPSMBFile *aFile = [tempFile mutableCopy];
            aFile.subFiles = tempArr;
            
            vc.file = aFile;
            
            tempFile = tempFile.parentFile;
            [vcArr insertObject:vc atIndex:0];
        } while (tempFile != nil);
        [vcArr insertObject:self atIndex:0];
        [self.navigationController setViewControllers:vcArr animated:YES];
#endif
        
    }
    else {
        __block DDPFile *tempFile = nil;
        DDPSMBFile *parentFile = file.parentFile;
        
        [[DDPToolsManager shareToolsManager] startDiscovererFileParentFolderWithChildrenFile:ddp_getANewRootFile() type:type completion:^(DDPFile *aFile) {
            
            [aFile.subFiles enumerateObjectsUsingBlock:^(__kindof DDPFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.fileURL relationshipWithURL:parentFile.fileURL] == NSURLRelationshipSame) {
                    tempFile = obj;
                    *stop = YES;
                }
            }];
            
            //没找到当前文件夹 则显示根目录
            if (tempFile == nil) {
                DDPLocalFileManagerPickerViewController *vc = [[DDPLocalFileManagerPickerViewController alloc] init];
                vc.file = aFile;
                vc.fileType = type;
                vc.selectedFileCallBack = selectedFileCallBack;
                [self.navigationController pushViewController:vc animated:YES ];
            }
            //找到则推出当前文件夹
            else {
                NSMutableArray *vcArr = [NSMutableArray array];
                do {
                    DDPLocalFileManagerPickerViewController *vc = [[DDPLocalFileManagerPickerViewController alloc] init];
                    vc.file = tempFile;
                    vc.fileType = type;
                    vc.selectedFileCallBack = selectedFileCallBack;
                    [vcArr insertObject:vc atIndex:0];
                } while ((tempFile = tempFile.parentFile));
                [vcArr insertObject:self atIndex:0];
                
                [self.navigationController setViewControllers:vcArr animated:YES];
            }
        }];
    }
}


//- (void)asynFilterDanmakuWithTime:(NSInteger)time {
//    //获取弹幕最大时间
//    NSInteger maxTime = [[self.danmakuDictionary.allKeys valueForKeyPath:@"@max.integerValue"] integerValue];
//
//    NSArray <DDPFilter *>*danmakuFilters = [DDPCacheManager shareCacheManager].danmakuFilters;
//
//    [_queue cancelAllOperations];
//
//    //主线程先分析一部分弹幕
//
//    for (NSInteger i = time; i < time + PARSE_TIME; ++i) {
//        NSMutableArray<JHBaseDanmaku *>* arr = self.danmakuDictionary[@(i)];
//        //已经分析过
//        if (arr == nil || [[arr getAssociatedValueForKey:_cmd] integerValue] == self.danmakuParseFlag) continue;
//
//        [arr enumerateObjectsUsingBlock:^(JHBaseDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self setDanmakuFilter:obj filter:[DDPDanmakuManager filterWithDanmakuContent:obj.text danmakuFilters:danmakuFilters]];
//        }];
//
//        [arr setAssociateValue:@(self.danmakuParseFlag) withKey:_cmd];
//    }
//
//    //子线程继续分析
//
//    NSBlockOperation *op = [[NSBlockOperation alloc] init];
//    @weakify(op)
//    [op addExecutionBlock:^{
//        @strongify(op)
//        if (!self || !op || op.isCancelled) return;
//
//
//        for (NSInteger i = time + PARSE_TIME; i <= maxTime; ++i) {
//            NSMutableArray<JHBaseDanmaku *>* arr = self.danmakuDictionary[@(i)];
//            //已经分析过
//            if (arr == nil || [[arr getAssociatedValueForKey:_cmd] integerValue] == self.danmakuParseFlag) continue;
//
//            [arr enumerateObjectsUsingBlock:^(JHBaseDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self setDanmakuFilter:obj filter:[DDPDanmakuManager filterWithDanmakuContent:obj.text danmakuFilters:danmakuFilters]];
//            }];
//            [arr setAssociateValue:@(self.danmakuParseFlag) withKey:_cmd];
//        }
//    }];
//
//    [_queue addOperation:op];
//
//}

//- (void)setDanmakuFilter:(JHBaseDanmaku *)danmaku filter:(BOOL)filter {
//    [_lock lock];
//    danmaku.filter = filter;
//    [_lock unlock];
//}

- (void)addNotice {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _addKeyPaths = @[DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuFont),
                     DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuSpeed),
                     DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuEffectStyle),
                     DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuOpacity),
                     DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuLimitCount),
                     DDP_KEYPATH([DDPCacheManager shareCacheManager], subtitleProtectArea)];
    [_addKeyPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew context:nil];
    }];
}

- (void)appWillResignActive:(NSNotification *)sender {
    //保存观看时间
    [[DDPCacheManager shareCacheManager] saveLastPlayTime:_currentTime videoModel:self.model];
    
    //本地视频不需要特殊处理
//    if (self.player.mediaType == DDPMediaTypeLocaleMedia) {
        _isPlay = self.player.isPlaying;
        [self.player pause];
//    }
//    else {
//        _isPlay = self.player.isPlaying;
//
//        _cacheCurrentTime = self.danmakuEngine.currentTime;
//        DDLogVerbose(@"退到后台保存时间：%@", ddp_mediaFormatterTime(_cacheCurrentTime));
////        [self.player setMediaURL:_model.fileURL];
//        [self.player stop];
//    }
}

- (void)appDidBecomeActive:(NSNotification *)sender {
//    if (self.player.mediaType == DDPMediaTypeLocaleMedia) {
        if (_isPlay) {
            [self.player play];
        }
//    }
//    else {
//        NSInteger time = _cacheCurrentTime;
//
//        DDLogVerbose(@"回到前台获取的时间：%@", ddp_mediaFormatterTime(time));
//
//        //更换视频
//        [self.player setMediaURL:self.model.fileURL];
//        @weakify(self)
//        [self.player parseWithCompletion:^{
//            @strongify(self)
//            if (!self) return;
//
//
//            [self.player play];
//            [self.player setCurrentTime:(int)time completionHandler:nil];
//            self.danmakuEngine.currentTime = time;
//
//            if (self->_isPlay == false) {
//                [self.player pause];
//                [self.danmakuEngine pause];
//            }
//        }];
//
//
//        //延迟一会 把时间调整到之前的位置
//
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////
////
////
////        });
//    }
}

#pragma mark - 懒加载
- (DDPPlayerInterfaceView *)interfaceView {
    if (_interfaceView == nil) {
        _interfaceView = [DDPPlayerInterfaceView creatWithPlayer:self.player];
        _interfaceView.delegate = self;
    }
    return _interfaceView;
}

- (DDPMediaPlayer *)player {
    if (_player == nil) {
        _player = [[DDPMediaPlayer alloc] init];
        _player.delegate = self;
        [DDPCacheManager shareCacheManager].mediaPlayer = _player;
    }
    return _player;
}

- (JHDanmakuEngine *)danmakuEngine {
    if (_danmakuEngine == nil) {
        _danmakuEngine = [[JHDanmakuEngine alloc] init];
        _danmakuEngine.delegate = self;
        [_danmakuEngine setUserInfoWithKey:JHScrollDanmakuExtraSpeedKey value:@([DDPCacheManager shareCacheManager].danmakuSpeed)];
        _danmakuEngine.canvas.alpha = [DDPCacheManager shareCacheManager].danmakuOpacity;
        _danmakuEngine.limitCount = [DDPCacheManager shareCacheManager].danmakuLimitCount;
    }
    return _danmakuEngine;
}

@end

