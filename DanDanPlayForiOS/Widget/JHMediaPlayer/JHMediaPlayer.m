//
//  JHMediaPlayer.m
//  test
//
//  Created by JimHuang on 16/3/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHMediaPlayer.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import <Photos/Photos.h>
#import "NSString+Tools.h"

//最大音量
#define MAX_VOLUME 200.0

@interface JHMediaPlayer()<VLCMediaPlayerDelegate>
@property (strong, nonatomic) VLCMediaPlayer *localMediaPlayer;
@property (copy, nonatomic) SnapshotCompleteBlock snapshotCompleteBlock;
@end

@implementation JHMediaPlayer
{
    NSTimeInterval _length;
    NSTimeInterval _currentTime;
    JHMediaPlayerStatus _status;
}

+ (instancetype)sharePlayer {
    static dispatch_once_t onceToken;
    static JHMediaPlayer *_player = nil;
    dispatch_once(&onceToken, ^{
        _player = [[JHMediaPlayer alloc] init];
    });
    return _player;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"] && [change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]] == NO) {
        NSLog(@"状态 %@", VLCMediaPlayerStateToString(self.localMediaPlayer.state));
        
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:statusChange:)]) {
            JHMediaPlayerStatus status = [self status];
            [self.delegate mediaPlayer:self statusChange:status];
        }
    }
}

- (void)dealloc {
    [_mediaView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_localMediaPlayer removeObserver:self forKeyPath:@"state"];
}


#pragma mark 属性
- (JHMediaType)mediaType {
    return [self.mediaURL isFileURL] ? JHMediaTypeLocaleMedia : JHMediaTypeNetMedia;
}

- (NSTimeInterval)length {
    if (_length > 0) return _length;
    
    _length = _localMediaPlayer.media.length.value.floatValue / 1000;
    return _length;
}

- (NSTimeInterval)currentTime {
    return _localMediaPlayer.time.value.floatValue / 1000;
}

- (JHMediaPlayerStatus)status {
    switch (_localMediaPlayer.state) {
        case VLCMediaPlayerStateStopped:
            _status = JHMediaPlayerStatusStop;
            break;
        case VLCMediaPlayerStatePaused:
            _status = JHMediaPlayerStatusPause;
            break;
        case VLCMediaPlayerStatePlaying:
        case VLCMediaPlayerStateBuffering:
            _status = JHMediaPlayerStatusPlaying;
            break;
        default:
            _status = JHMediaPlayerStatusPause;
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

- (void)setPosition:(CGFloat)position completionHandler:(void(^)(NSTimeInterval time))completionHandler {
    if (position < 0) position = 0;
    if (position > 1) position = 1;
    
    _localMediaPlayer.position = position;
    if (completionHandler) completionHandler([self length] * position);
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

- (void)setSpeed:(float)speed {
    _localMediaPlayer.rate = speed;
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:rateChange:)]) {
        [self.delegate mediaPlayer:self rateChange:_localMediaPlayer.rate];
    }
}

- (float)speed {
    return _localMediaPlayer.rate;
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
    
    NSString *aPath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", [NSDate date].hash]];
    if ([_mediaURL.absoluteString containsString:@"smb"]) {
        UIView *aView = self.localMediaPlayer.drawable;
        UIImage *tempImage = [aView snapshotImageAfterScreenUpdates:YES];
        [self saveImage:tempImage];
    }
    else {
        [self.localMediaPlayer saveVideoSnapshotAt:aPath withWidth:size.width andHeight:size.height];
    }
}

- (int)openVideoSubTitlesFromFile:(NSURL *)path {
    //    if (self.mediaType == JHMediaTypeLocaleMedia) {
    return [_localMediaPlayer addPlaybackSlave:path type:VLCMediaPlaybackSlaveTypeSubtitle enforce:YES];
    //    }
    
    //    return [_localMediaPlayer openVideoSubTitlesFromFile:a];
}

- (void)setMediaURL:(NSURL *)mediaURL {
    //    [self stop];
    if (!mediaURL) return;
    _mediaURL = mediaURL;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_mediaURL.path] || [_mediaURL.scheme isEqualToString:@"smb"]) {
        VLCMedia *media = [[VLCMedia alloc] initWithURL:mediaURL];
        [media addOptions:@{@"freetype-font" : @"Helvetica Neue"}];
        self.localMediaPlayer.media = media;
    }
    
    self.localMediaPlayer.delegate = self;
    _length = -1;
}

- (instancetype)initWithMediaURL:(NSURL *)mediaURL {
    if (self = [super init]) {
        [self setMediaURL:mediaURL];
    }
    return self;
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:progress:currentTime:totalTime:)]) {
        NSTimeInterval nowTime = [self currentTime];
        NSTimeInterval videoTime = [self length];
        
        NSString *nowDateTime = jh_mediaFormatterTime(nowTime);
        NSString *videoDateTime = jh_mediaFormatterTime(videoTime);
        
        if (!(videoDateTime && nowDateTime)) return;
        [self.delegate mediaPlayer:self progress:nowTime / videoTime currentTime:nowDateTime totalTime:videoDateTime];
    }
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    UIImage *tempImage = self.localMediaPlayer.lastSnapshot;
    [self saveImage:tempImage];
}

#pragma mark - 私有方法
- (void)saveImage:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.snapshotCompleteBlock) {
                    self.snapshotCompleteBlock(image, nil);
                    self.snapshotCompleteBlock = nil;
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.snapshotCompleteBlock) {
                    self.snapshotCompleteBlock(nil, error);
                    self.snapshotCompleteBlock = nil;
                }
            });
        }
    }];
}

#pragma mark 播放结束
- (void)playEnd:(NSNotification *)sender {
    if (self.mediaType == JHMediaTypeNetMedia) {
        _status = JHMediaPlayerStatusStop;
        if ([self.delegate respondsToSelector:@selector(mediaPlayer:statusChange:)]) {
            [self.delegate mediaPlayer:self statusChange:JHMediaPlayerStatusStop];
        }
    }
}

#pragma mark - 懒加载
- (VLCMediaPlayer *)localMediaPlayer {
    if(_localMediaPlayer == nil) {
        _localMediaPlayer = [[VLCMediaPlayer alloc] init];
        _localMediaPlayer.drawable = self.mediaView;
        _localMediaPlayer.delegate = self;
        [_localMediaPlayer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _localMediaPlayer;
}

- (UIView *)mediaView {
    if (_mediaView == nil) {
        _mediaView = [[UIView alloc] init];
    }
    return _mediaView;
}

@end
