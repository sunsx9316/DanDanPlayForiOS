//
//  DDPCacheManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHBaseDanmaku.h"
#import "DDPSMBInfo.h"

/**
 视频播放模式

 - DDPPlayerPlayModeSingle: 单集播放
 - DDPPlayerPlayModeSingleCircle: 单集循环
 - DDPPlayerPlayModeCircle: 列表循环
 - DDPPlayerPlayModeOrder: 顺序播放
 */
typedef NS_ENUM(NSUInteger, DDPPlayerPlayMode) {
    DDPPlayerPlayModeSingle,
    DDPPlayerPlayModeSingleCircle,
    DDPPlayerPlayModeCircle,
    DDPPlayerPlayModeOrder,
};

typedef NS_ENUM(NSUInteger, DDPCollectionCacheDidChangeType) {
    DDPCollectionCacheDidChangeTypeAdd,
    DDPCollectionCacheDidChangeTypeRemove,
};

//FOUNDATION_EXPORT NSString *const videoNameKey;
//FOUNDATION_EXPORT NSString *const videoEpisodeIdKey;

//缓存所有弹幕的标识
#define CACHE_ALL_DANMAKU_FLAG 9999

@class DDPUser, DDPFile, TOSMBSessionFile, TOSMBSessionDownloadTask, DDPMediaPlayer, DDPCollectionCache, DDPSMBFileHashCache;

@protocol DDPCacheManagerDelagate <NSObject>
@optional

- (void)lastPlayTimeWithVideoModel:(DDPVideoModel *)videoModel time:(NSInteger)time;
- (void)collectionDidHandleCache:(DDPCollectionCache *)cache operation:(DDPCollectionCacheDidChangeType)operation;
@end

@interface DDPCacheManager : NSObject

@property (weak, nonatomic) DDPMediaPlayer *mediaPlayer;

/**
 当前登录的用户
 */
@property (strong, nonatomic) DDPUser *user;

/**
 上次登录的用户
 */
@property (strong, nonatomic) DDPUser *lastLoginUser;

/**
 当前连接信息
 */
@property (strong, nonatomic) DDPLinkInfo *linkInfo;

/**
 弹幕字体
 */
@property (strong, nonatomic) UIFont *danmakuFont;

/**
 弹幕边缘特效
 */
@property (assign, nonatomic) JHDanmakuShadowStyle danmakuShadowStyle;

/**
 字幕保护区域
 */
@property (assign, nonatomic) BOOL subtitleProtectArea;


/**
 弹幕缓存时间 默认7天
 */
@property (assign, nonatomic) NSUInteger danmakuCacheTime;

/**
 自动请求第三方弹幕
 */
@property (assign, nonatomic) BOOL autoRequestThirdPartyDanmaku;

/**
 是否打开快速匹配
 */
@property (assign, nonatomic) BOOL openFastMatch;

/**
 是否自动下载远程设备字幕
 */
@property (assign, nonatomic) BOOL openAutoDownloadSubtitle;

/**
 使用touchId登录
 */
@property (assign, nonatomic) BOOL useTouchIdLogin;


/**
 显示下载状态视图
 */
@property (assign, nonatomic) BOOL showDownloadStatusView;

/**
 播放器播放模式
 */
@property (assign, nonatomic) DDPPlayerPlayMode playMode;

/**
 弹幕速度
 */
@property (assign, nonatomic) float danmakuSpeed;

/**
 弹幕不透明度
 */
@property (assign, nonatomic) float danmakuOpacity;


/**
 选择的弹幕颜色
 */
@property (strong, nonatomic) UIColor *sendDanmakuColor;

/**
 选择的弹幕类型
 */
@property (assign, nonatomic) DDPDanmakuMode sendDanmakuMode;


/**
 同屏弹幕数量 默认14
 */
@property (assign, nonatomic) NSUInteger danmakuLimitCount;


/**
 播放页默认旋屏位置
 */
@property (assign, nonatomic) UIInterfaceOrientation playInterfaceOrientation;

/**
 存储文件夹名称和文件hash
 */
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <NSString *>*>*folderCache;

//当前分析的视频模型
@property (strong, nonatomic) DDPVideoModel *currentPlayVideoModel;

+ (instancetype)shareCacheManager;
@end
