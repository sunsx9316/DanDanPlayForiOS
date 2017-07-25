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

//最大音量
#define MAX_VOLUME 200.0

@interface JHMediaPlayer()<VLCMediaPlayerDelegate>
@property (strong, nonatomic) VLCMediaPlayer *localMediaPlayer;
//@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation JHMediaPlayer
{
    NSTimeInterval _length;
    NSTimeInterval _currentTime;
    JHMediaPlayerStatus _status;
//    VLCMedia *_currentLocalMedia;
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
        default:
            _status = JHMediaPlayerStatusPlaying;
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
- (void)saveVideoSnapshotwithSize:(CGSize)size completionHandler:(snapshotCompleteBlock)completion {
    //vlc截图方式
    NSError *error = nil;
    NSString *directoryPath = [NSString stringWithFormat:@"%@/VLC_snapshot/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, [NSDate date]];
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
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_localMediaPlayer saveVideoSnapshotAt:directoryPath withWidth:size.width andHeight:size.height];
        
        UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:directoryPath];
        
//        NSMutableArray *imageIds = [NSMutableArray array];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //写入图片到相册
            /*PHAssetChangeRequest *req = */[PHAssetChangeRequest creationRequestForAssetFromImage:tempImage];
            //记录本地标识，等待完成后取到相册中的图片对象
//            [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                if (completion) {
                completion(tempImage, nil);
            }
                //成功后取相册中的图片对象
//                __block PHAsset *imageAsset = nil;
//                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
//                [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    
//                    imageAsset = obj;
//                    *stop = YES;
//                    
//                }];
//                
//                if (imageAsset) {
//                    //加载图片数据
//                    [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                        if (completion) {
//                            completion([[UIImage alloc] initWithData:imageData], nil);
//                        }
//                    }];
//                }
            }
            else {
                if (completion) {
                    completion(nil, error);
                }
            }
            
        }];
    });
}

- (int)openVideoSubTitlesFromFile:(NSURL *)path {
//    if (self.mediaType == JHMediaTypeLocaleMedia) {
    return [_localMediaPlayer addPlaybackSlave:path type:VLCMediaPlaybackSlaveTypeSubtitle enforce:YES];
//    }
//    return [_localMediaPlayer openVideoSubTitlesFromFile:b];
}

- (void)setMediaURL:(NSURL *)mediaURL {
//    [self stop];
    if (!mediaURL) return;
    
    _mediaURL = mediaURL;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_mediaURL.path] || [_mediaURL.absoluteString hasPrefix:@"smb://"]) {
        self.localMediaPlayer.media = [[VLCMedia alloc] initWithURL:mediaURL];
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
//        NSString *nowDateTime = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:nowTime]];
//        NSString *videoDateTime = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:videoTime]];
        
        NSString *nowDateTime = jh_mediaFormatterTime(nowTime);
        NSString *videoDateTime = jh_mediaFormatterTime(videoTime);
        
        if (!(videoDateTime && nowDateTime)) return;
        [self.delegate mediaPlayer:self progress:nowTime / videoTime currentTime:nowDateTime totalTime:videoDateTime];
    }
}

//- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
//    
//    NSLog(@"状态 %@", VLCMediaPlayerStateToString(self.localMediaPlayer.state));
//    
//    if ([self.delegate respondsToSelector:@selector(mediaPlayer:statusChange:)]) {
//        JHMediaPlayerStatus status = [self status];
//        if (status == JHMediaPlayerStatusStop && self.localMediaPlayer.isPlaying == NO) {
//            [self.delegate mediaPlayer:self statusChange:JHMediaPlayerStatusStop];
//        }
//        else {
//            [self.delegate mediaPlayer:self statusChange:status];
//        }
//    }
//}

#pragma mark - 私有方法

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
//        _localMediaPlayer.libraryInstance.debugLogging = NO;
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

//- (NSDateFormatter *)dateFormatter {
//    if(_dateFormatter == nil) {
//        _dateFormatter = [[NSDateFormatter alloc] init];
//        _dateFormatter.dateFormat = _timeFormat?_timeFormat:@"mm:ss";
//    }
//    return _dateFormatter;
//}

@end
