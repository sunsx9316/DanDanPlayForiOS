//
//  DDPMethod.h
//  DDPForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPMacroDefinition.h"
#import "DDPConstant.h"

@class DDPFile, DDPLinkFile, DDPVideoModel, DDPDanmakuCollection;

typedef void(^DDPFastMatchAction)(DDPDanmakuCollection *collection, NSError *error);

CG_INLINE BOOL ddp_isPad() {
    return [UIDevice currentDevice].isPad;
};

CG_INLINE NSString *ddp_subtitleDownloadPath() {
    NSString *path = [[UIApplication sharedApplication].documentsPath stringByAppendingPathComponent:@"subtitle"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

CG_INLINE NSString *ddp_danmakuDownloadPath() {
    NSString *path = [[UIApplication sharedApplication].documentsPath stringByAppendingPathComponent:@"danmaku"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

CG_INLINE NSURL *ddp_linkImageURL(NSString *ip, NSString *hash) {
    if (hash.length == 0) return nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/image/%@", ip, LINK_API_INDEX, hash]];
}

CG_INLINE NSURL *ddp_linkVideoURL(NSString *ip, NSString *hash) {
    if (hash.length == 0) return nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/stream/id/%@", ip, LINK_API_INDEX, hash]];
}

CG_INLINE NSString *ddp_taskDownloadPath() {
    return [UIApplication sharedApplication].documentsPath;
}


/**
 弹弹弹幕颜色的计算公式

 @param color 颜色
 @return 弹幕颜色
 */
CG_INLINE uint32_t ddp_danmakuColor(UIColor *color) {
    CGFloat r, g, b = 0;
    [color getRed:&r green:&g blue:&b alpha:nil];
    
    return r * 256 * 256 * 255 + g * 256 * 255 + b * 255;
}


/**
 分集类型转字符串

 @param type 类型
 @return 字符串
 */
//UIKIT_EXTERN NSString *DDPEpisodeTypeToString(DDPEpisodeType type);

/**
 根据错误编号生成错误对象

 @param code 编号
 @return 对象
 */
UIKIT_EXTERN NSError *DDPErrorWithCode(DDPErrorCode code);


/**
 快速生成颜色

 @param r 红
 @param g 绿
 @param b 蓝
 @return 颜色
 */
UIKIT_EXTERN UIColor *DDPRGBColor(int r, int g, int b);

/**
 快速生成颜色

 @param r 红
 @param g 绿
 @param b 蓝
 @param a 透明度
 @return 颜色
 */
UIKIT_EXTERN UIColor *DDPRGBAColor(int r, int g, int b, CGFloat a);


UIKIT_EXTERN DDPDanmakuType ddp_danmakuStringToType(NSString *string);
UIKIT_EXTERN NSString *ddp_danmakuTypeToString(DDPDanmakuType type);

/**
 判断路径是不是字幕
 
 @param aURL 路径
 @return 是不是字幕
 */
UIKIT_EXTERN BOOL ddp_isSubTitleFile(NSString *aURL);
/**
 判断文件是不是视频
 
 @param aURL 路径
 @return 是不是视频
 */
UIKIT_EXTERN BOOL ddp_isVideoFile(NSString *aURL);

/**
 判断路径是不是弹幕文件
 
 @param aURL 路径
 @return 是不是弹幕
 */
UIKIT_EXTERN BOOL ddp_isDanmakuFile(NSString *aURL);


/**
 生成一个根目录文件夹
 
 @return 根目录
 */
UIKIT_EXTERN DDPFile *ddp_getANewRootFile(void);


/**
 生成一个PC的根目录对象
 
 @return 根目录
 */
UIKIT_EXTERN DDPLinkFile *ddp_getANewLinkRootFile(void);


/**
 判断路径是不是根目录
 
 @param file 文件
 @return    是不是根目录
 */
UIKIT_EXTERN BOOL ddp_isRootFile(DDPFile *file);


/**
 判断路径是不是根目录

 @param path 路径
 @return 是不是根目录
 */
UIKIT_EXTERN BOOL ddp_isRootPath(NSString *path);


/**
 是否为小屏幕设备

 @return 是否为小屏幕设备
 */
UIKIT_EXTERN BOOL ddp_isSmallDevice(void);


/**
 是否为横屏

 @return 是否为横屏
 */
UIKIT_EXTERN BOOL ddp_isLandscape(void);


/**
 是否安装了国内常见app

 @return 是否安装了国内常见app
 */
UIKIT_EXTERN BOOL ddp_isChatAppInstall(void);

@interface DDPMethod : NSObject

/**
 请求路径

 @return 请求路径
 */
+ (NSString *)apiPath;

/**
 v2请求路径

 @return v2请求路径
 */
+ (NSString *)apiNewPath;

/// 检查更新地址
+ (NSString *)checkVersionPath;


/// 匹配文件/文件夹
/// @param file 文件
+ (void)matchFile:(DDPFile *)file
       completion:(DDPFastMatchAction)completion;

/// 匹配视频模型
/// @param model 视频模型
/// @param completion 完成回调
+ (void)matchVideoModel:(DDPVideoModel *)model
             completion:(DDPFastMatchAction)completion;

/// 匹配视频模型
/// @param model 视频模型
/// @param useDefaultMode 使用默认处理方式
/// @param completion 完成回调
+ (void)matchVideoModel:(DDPVideoModel *)model
         useDefaultMode:(BOOL)useDefaultMode
             completion:(DDPFastMatchAction)completion;

#if DDPAPPTYPEISMAC
///  发送匹配成功消息
/// @param model 消息
+ (void)sendMatchedModelMessage:(DDPVideoModel *)model;

/// 同步全量配置消息
+ (void)sendConfigMessage;
#endif
@end
