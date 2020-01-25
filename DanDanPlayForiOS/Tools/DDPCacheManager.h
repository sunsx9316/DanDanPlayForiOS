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


/**
 屏蔽弹幕类型

 - DDPDanmakuShieldTypeScrollToLeft: 滚动到左边
 - DDPDanmakuShieldTypeScrollToRight: 滚动到右边
 - DDPDanmakuShieldTypeScrollToTop: 滚动到顶部
 - DDPDanmakuShieldTypeScrollToBottom: 滚动到底部
 - DDPDanmakuShieldTypeFloatAtTo: 浮动在顶部
 - DDPDanmakuShieldTypeFloatAtBottom: 浮动在底部
 - DDPDanmakuShieldTypeColor: 彩色弹幕
 - DDPDanmakuShieldTypeScroll: 所有滚动弹幕
 - DDPDanmakuShieldTypeFloat: 所以浮动弹幕
 */
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

typedef NS_ENUM(NSUInteger, DDPFileSortType) {
    DDPFileSortTypeAsc,
    DDPFileSortTypeDesc,
};

//缓存所有弹幕的标识
#define CACHE_ALL_DANMAKU_FLAG 9999

@class DDPUser, DDPFile, TOSMBSessionFile, TOSMBSessionDownloadTask, DDPMediaPlayer, DDPCollectionCache, DDPSMBFileHashCache;

@protocol DDPCacheManagerDelagate <NSObject>
@optional

- (void)lastPlayTimeWithVideoModel:(DDPVideoModel *)videoModel time:(NSInteger)time;
- (void)collectionDidHandleCache:(DDPCollectionCache *)cache operation:(DDPCollectionCacheDidChangeType)operation;
- (void)userLoginStatusDidChange:(DDPUser *)user;
- (void)linkInfoDidChange:(DDPLinkInfo *)linkInfo;
@end

@interface DDPCacheManager : NSObject

@property (weak, nonatomic) DDPMediaPlayer *mediaPlayer;

/**
 当前登录的用户
 */
@property (strong, nonatomic) DDPUser *currentUser;

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
@property (assign, nonatomic) JHDanmakuEffectStyle danmakuEffectStyle;

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
 是否自动下载局域网设备字幕
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
 屏蔽弹幕类型
 */
@property (assign, nonatomic) DDPDanmakuShieldType danmakuShieldType;


/**
 用于请求的域名
 */
@property (copy, nonatomic) NSString *userDefineRequestDomain;


/**
 文件排序类型
 */
@property (assign, nonatomic) DDPFileSortType fileSortType;

/**
 存储文件夹名称和文件hash
 */
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <NSString *>*>*folderCache;

//当前分析的视频模型
@property (strong, nonatomic) DDPVideoModel *currentPlayVideoModel;


/**
 刷新中显示的文字
 */
@property (strong, nonatomic) NSMutableArray <NSString *>*refreshTexts;


/**
 弹幕偏移时间 不进行本地保存
 */
@property (assign, nonatomic) CGFloat danmakuOffsetTime;

/// 视频比例
@property (assign, nonatomic) CGSize videoAspectRatio;

/// 播放速率
@property (assign, nonatomic) float playerSpeed;

/// 上次忽略的版本
@property (copy, nonatomic) NSString *ignoreVersion;

/// 引导视图是否显示过
@property (nonatomic, assign) BOOL guildViewIsShow;

/// 自动加载本地弹幕
@property (nonatomic, assign) BOOL loadLocalDanmaku;

+ (instancetype)shareCacheManager;
@end
