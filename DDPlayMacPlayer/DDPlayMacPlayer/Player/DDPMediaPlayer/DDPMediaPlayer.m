//
//  DDPMediaPlayer.m
//  test
//
//  Created by JimHuang on 16/3/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPMediaPlayer.h"
#import <VLCKit/VLCKit.h>
#import <objc/runtime.h>
//#import <Photos/Photos.h>
//#import "NSString+Tools.h"

//最大音量
#define MAX_VOLUME 200.0

static char mediaParsingCompletionKey = '0';

@interface DDPMediaPlayer()<VLCMediaPlayerDelegate, VLCMediaDelegate>
@property (strong, nonatomic) VLCMediaPlayer *localMediaPlayer;
@property (copy, nonatomic) SnapshotCompleteBlock snapshotCompleteBlock;
@end

@implementation DDPMediaPlayer
{
    NSTimeInterval _length;
    NSTimeInterval _currentTime;
    DDPMediaPlayerStatus _status;
}

- (instancetype)initWithMediaURL:(NSURL *)mediaURL {
    if (self = [self init]) {
        [self setMediaURL:mediaURL];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)dealloc {
    [_mediaView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    free(_localMediaPlayer.videoAspectRatio);
    _localMediaPlayer.drawable = nil;
    _localMediaPlayer = nil;
    self.mediaView = nil;
}

- (void)parseWithCompletion:(void(^)(void))completion {
    objc_setAssociatedObject(self.localMediaPlayer.media, &mediaParsingCompletionKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    let media = self.localMediaPlayer.media;
    let result = [media parseWithOptions:VLCMediaParseLocal | VLCMediaParseNetwork];
    
    if (result != 0) {
        JHLog(@"%@", @"解析失败");
    }
}


#pragma mark 属性
- (DDPMediaType)mediaType {
    return [self.mediaURL isFileURL] ? DDPMediaTypeLocaleMedia : DDPMediaTypeNetMedia;
}

- (NSTimeInterval)length {
    if (_length > 0) return _length;
    
    _length = _localMediaPlayer.media.length.value.floatValue / 1000.0f;
    return _length;
}

- (NSTimeInterval)currentTime {
    return _localMediaPlayer.time.value.floatValue / 1000.0f;
}

- (DDPMediaPlayerStatus)status {
    switch (_localMediaPlayer.state) {
        case VLCMediaPlayerStateStopped:
            if (self.localMediaPlayer.position >= 0.999) {
                _status = DDPMediaPlayerStatusNextEpisode;
            }
            else {
                _status = DDPMediaPlayerStatusStop;
            }
            break;
        case VLCMediaPlayerStatePaused:
            _status = DDPMediaPlayerStatusPause;
            break;
        case VLCMediaPlayerStatePlaying:
            _status = DDPMediaPlayerStatusPlaying;
            break;
        case VLCMediaPlayerStateBuffering:
            if (self.localMediaPlayer.isPlaying) {
                _status = DDPMediaPlayerStatusPlaying;
            }
            else {
                _status = DDPMediaPlayerStatusPause;
            }
            break;
        default:
            _status = DDPMediaPlayerStatusPause;
            break;
    }
    return _status;
}

#pragma mark 音量
- (void)volumeJump:(CGFloat)value {
    [self setVolume: self.volume + value];
}

- (CGFloat)volume {
    return _localMediaPlayer.audio.volume;
}

- (void)setVolume:(CGFloat)volume {
    if (volume < 0) volume = 0;
    if (volume > MAX_VOLUME) volume = MAX_VOLUME;
    
    _localMediaPlayer.audio.volume = volume;
}

#pragma mark 播放位置
- (void)jump:(int)value completionHandler:(void(^)(NSTimeInterval time))completionHandler {
    [self setPosition:([self currentTime] + value) / [self length] completionHandler:completionHandler];
}

- (void)setCurrentTime:(int)time completionHandler:(void(^)(NSTimeInterval time))completionHandler {
    [self setPosition:time / [self length] completionHandler:completionHandler];
}

- (void)setPosition:(CGFloat)position completionHandler:(void(^)(NSTimeInterval time))completionHandler {
    if (position < 0) position = 0;
    if (position > 1) position = 1;
    
    _localMediaPlayer.position = position;
    NSTimeInterval jumpTime = [self length] * position;
    
    if (completionHandler) completionHandler(jumpTime);
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:userJumpWithTime:)]) {
        [self.delegate mediaPlayer:self userJumpWithTime:jumpTime];
    }
}

- (CGFloat)position {
    return _localMediaPlayer.position;
}

#pragma mark 字幕
- (void)setSubtitleDelay:(NSInteger)subtitleDelay {
    _localMediaPlayer.currentVideoSubTitleDelay = subtitleDelay;
}

- (NSInteger)subtitleDelay {
    return _localMediaPlayer.currentVideoSubTitleDelay;
}

- (NSArray *)subtitleIndexs {
    return _localMediaPlayer.videoSubTitlesIndexes;
}

- (NSArray *)subtitleTitles {
    return _localMediaPlayer.videoSubTitlesNames;
}

- (void)setCurrentSubtitleIndex:(int)currentSubtitleIndex {
    _localMediaPlayer.currentVideoSubTitleIndex = currentSubtitleIndex;
}

- (int)currentSubtitleIndex {
    return _localMediaPlayer.currentVideoSubTitleIndex;
}


- (NSArray<NSNumber *> *)audioChannelIndexs {
    return _localMediaPlayer.audioTrackIndexes;
}

- (NSArray<NSString *> *)audioChannelTitles {
    return _localMediaPlayer.audioTrackIndexes;
}

- (void)setCurrentAudioChannelIndex:(int)currentAudioChannelIndex {
    _localMediaPlayer.audioChannel = currentAudioChannelIndex;
}

- (int)currentAudioChannelIndex {
    return _localMediaPlayer.audioChannel;
}


- (void)setSpeed:(float)speed {
    _localMediaPlayer.rate = speed;
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:rateChange:)]) {
        [self.delegate mediaPlayer:self rateChange:_localMediaPlayer.rate];
    }
}

- (float)speed {
    return _localMediaPlayer.rate;
}

- (void)setVideoAspectRatio:(CGSize)videoAspectRatio {
    if (CGSizeEqualToSize(videoAspectRatio, CGSizeZero)) {
        self.localMediaPlayer.videoAspectRatio = nil;
    }
    else {
        self.localMediaPlayer.videoAspectRatio = (char *)[NSString stringWithFormat:@"%ld:%ld", (long)videoAspectRatio.width, (long)videoAspectRatio.height].UTF8String;
    }
}

#pragma mark 播放器控制
- (BOOL)isPlaying {
    return [_localMediaPlayer isPlaying];
}

- (void)play {
    [_localMediaPlayer play];
}

- (void)pause {
    [_localMediaPlayer pause];
}

- (void)stop {
    [_localMediaPlayer stop];
}


#pragma mark 功能
- (void)saveVideoSnapshotwithSize:(CGSize)size completionHandler:(SnapshotCompleteBlock)completion {
    //vlc截图方式
    NSError *error = nil;
    NSString *directoryPath = [NSString stringWithFormat:@"%@/VLC_snapshot", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    //创建文件错误
    if (error) {
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    
    self.snapshotCompleteBlock = completion;
    
    NSString *aPath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate date].hash]];
    [self.localMediaPlayer saveVideoSnapshotAt:aPath withWidth:size.width andHeight:size.height];
}

- (int)openVideoSubTitlesFromFile:(NSURL *)path {
    //    if (self.mediaType == DDPMediaTypeLocaleMedia) {
    return [_localMediaPlayer addPlaybackSlave:path type:VLCMediaPlaybackSlaveTypeSubtitle enforce:YES];
    //    }
    
    //    return [_localMediaPlayer openVideoSubTitlesFromFile:a];
}

- (void)setMediaURL:(NSURL *)mediaURL {
    if (!mediaURL) return;
    
    _mediaURL = mediaURL;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_mediaURL.path] || [_mediaURL.scheme isEqualToString:@"smb"] || [_mediaURL.scheme isEqualToString:@"http"]) {
        VLCMedia *media = [[VLCMedia alloc] initWithURL:mediaURL];
        media.delegate = self;
        self.localMediaPlayer.media = media;
    }
    
    _length = -1;
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:currentTime:totalTime:)]) {
        NSTimeInterval nowTime = [self currentTime];
        NSTimeInterval videoTime = [self length];
        [self.delegate mediaPlayer:self currentTime:nowTime totalTime:videoTime];
    }
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    NSImage *tempImage = self.localMediaPlayer.lastSnapshot;
    [self saveImage:tempImage];
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
//    DDLogVerbose(@"状态 %@", VLCMediaPlayerStateToString(self.localMediaPlayer.state));
    
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:statusChange:)]) {
        DDPMediaPlayerStatus status = [self status];
        [self.delegate mediaPlayer:self statusChange:status];
    }
}

- (void)mediaDidFinishParsing:(VLCMedia *)aMedia {
    void(^action)(void) = objc_getAssociatedObject(aMedia, &mediaParsingCompletionKey);
    if (action) {
        action();
    }
    
    objc_setAssociatedObject(aMedia, &mediaParsingCompletionKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 私有方法
- (void)saveImage:(NSImage *)image {
    
}

#pragma mark 播放结束
- (void)playEnd:(NSNotification *)sender {
    if (self.mediaType == DDPMediaTypeNetMedia) {
        _status = DDPMediaPlayerStatusStop;
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:statusChange:)]) {
            [self.delegate mediaPlayer:self statusChange:DDPMediaPlayerStatusStop];
        }
    }
}

#pragma mark - 懒加载
- (VLCMediaPlayer *)localMediaPlayer {
    if(_localMediaPlayer == nil) {
        _localMediaPlayer = [[VLCMediaPlayer alloc] init];
        _localMediaPlayer.drawable = self.mediaView;
        _localMediaPlayer.delegate = self;
    }
    return _localMediaPlayer;
}

- (NSView *)mediaView {
    if (_mediaView == nil) {
        VLCVideoView *mediaView = [[VLCVideoView alloc] init];
        mediaView.fillScreen = YES;
        
        _mediaView = mediaView;
    }
    return _mediaView;
}

@end
