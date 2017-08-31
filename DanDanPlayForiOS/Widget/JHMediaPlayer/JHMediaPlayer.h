//
//  JHMediaPlayer.h
//  test
//
//  Created by JimHuang on 16/3/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JHMediaPlayerStatus) {
    JHMediaPlayerStatusPlaying,
    JHMediaPlayerStatusPause,
    JHMediaPlayerStatusStop,
    JHMediaPlayerStatusBuffering
};

typedef NS_ENUM(NSUInteger, JHMediaType) {
    JHMediaTypeLocaleMedia,
    JHMediaTypeNetMedia,
};

typedef NS_ENUM(NSUInteger, JHSnapshotType) {
    JHSnapshotTypeJPG,
    JHSnapshotTypePNG,
    JHSnapshotTypeBMP,
    JHSnapshotTypeTIFF
};


typedef void(^SnapshotCompleteBlock)(UIImage *image, NSError *error);


/**
 转换秒数为指定格式

 @param totalSeconds 秒数
 @return 指定格式
 */
CG_INLINE NSString *jh_mediaFormatterTime(int totalSeconds) {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds - seconds) / 60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds];
}

@class JHMediaPlayer;
@protocol JHMediaPlayerDelegate <NSObject>
@optional
/**
 *  监听时间变化
 *
 *  @param player    Player
 *  @param progress  当前进度
 *  @param fomatTime 格式化之后的时间
 */
- (void)mediaPlayer:(JHMediaPlayer *)player progress:(float)progress currentTime:(NSString *)currentTime totalTime:(NSString *)totalTime;

- (void)mediaPlayer:(JHMediaPlayer *)player statusChange:(JHMediaPlayerStatus)status;

- (void)mediaPlayer:(JHMediaPlayer *)player rateChange:(float)rate;
@end


@interface JHMediaPlayer : NSObject

+ (instancetype)sharePlayer;

@property (strong, nonatomic) UIView *mediaView;
@property (strong, nonatomic) NSURL *mediaURL;
@property (assign, nonatomic) CGFloat volume;
@property (assign, nonatomic) NSInteger subtitleDelay;
@property (strong, nonatomic, readonly) NSArray *subtitleIndexs;
@property (strong, nonatomic, readonly) NSArray *subtitleTitles;
@property (assign, nonatomic) int currentSubtitleIndex;
@property (assign, nonatomic) float speed;
/**
 *  位置 0 ~ 1
 */
- (CGFloat)position;
/**
 *  设置媒体位置
 *
 *  @param position          位置 0 ~ 1
 *  @param completionHandler 完成之后的回调
 */
- (void)setPosition:(CGFloat)position completionHandler:(void(^)(NSTimeInterval time))completionHandler;
/**
 *  协议返回的时间格式 默认"mm:ss"
 */
@property (strong, nonatomic) NSString *timeFormat;
@property (weak, nonatomic) id <JHMediaPlayerDelegate>delegate;
- (JHMediaPlayerStatus)status;
- (NSTimeInterval)length;
- (NSTimeInterval)currentTime;
- (JHMediaType)mediaType;
/**
 *  媒体跳转
 *
 *  @param value 增加的值
 */
- (void)jump:(int)value completionHandler:(void(^)(NSTimeInterval time))completionHandler;
/**
 *  音量增加
 *
 *  @param value 增加的值
 */
- (void)volumeJump:(CGFloat)value;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
/**
 *  保存截图
 *
 *  @param size  宽 如果为 CGSizeZero则为原视频的宽高
 *  @param height 高 如果填0则为原视频高
 */
- (void)saveVideoSnapshotwithSize:(CGSize)size completionHandler:(SnapshotCompleteBlock)completion;
/**
 *  加载字幕文件
 *
 *  @param path 字幕路径
 *
 *  @return 是否成功 0失败 1成功
 */
- (int)openVideoSubTitlesFromFile:(NSURL *)path;
/**
 *  初始化
 *
 *  @param mediaURL 媒体路径 可以为本地视频或者网络视频
 *
 *  @return self
 */
- (instancetype)initWithMediaURL:(NSURL *)mediaURL;

@end
