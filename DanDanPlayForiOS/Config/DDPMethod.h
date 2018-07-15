//
//  DDPMethod.h
//  DDPForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPMacroDefinition.h"

@class DDPFile, DDPLinkFile;

/**
 弹幕类型

 - DDPDanmakuTypeUnknow: 未知类型
 - DDPDanmakuTypeOfficial: 官方弹幕
 - DDPDanmakuTypeBiliBili: b站弹幕
 - DDPDanmakuTypeAcfun: a站弹幕
 - DDPDanmakuTypeByUser: 用户发送的弹幕
 */
typedef NS_ENUM(NSUInteger, DDPDanmakuType) {
    DDPDanmakuTypeUnknow = 1 << 0,
    DDPDanmakuTypeOfficial = 1 << 1,
    DDPDanmakuTypeBiliBili = 1 << 2,
    DDPDanmakuTypeAcfun = 1 << 3,
    DDPDanmakuTypeByUser = 1 << 4,
};


/**
 节目类型

 - DDPEpisodeTypeAnimate: TV动画
 - DDPEpisodeTypeAnimateSpecial: TV动画特别放送
 - DDPEpisodeTypeOVA: OVA
 - DDPEpisodeTypePalgantong: 剧场版
 - DDPEpisodeTypeMV: 音乐视频（MV）
 - DDPEpisodeTypeWeb: 网络放送
 - DDPEpisodeTypeOther: 其他分类
 - DDPEpisodeTypeThreeDMovie: 三次元电影
 - DDPEpisodeTypeThreeDTVPlayOrChineseAnimate: 三次元电视剧或国产动画
 - DDPEpisodeTypeUnknow: 未知（尚未分类）
 */
typedef NS_ENUM(NSInteger, DDPEpisodeType) {
    DDPEpisodeTypeAnimate = 1,
    DDPEpisodeTypeAnimateSpecial,
    DDPEpisodeTypeOVA,
    DDPEpisodeTypePalgantong,
    DDPEpisodeTypeMV,
    DDPEpisodeTypeWeb,
    DDPEpisodeTypeOther,
    DDPEpisodeTypeThreeDMovie = 10,
    DDPEpisodeTypeThreeDTVPlayOrChineseAnimate = 20,
    DDPEpisodeTypeUnknow = 99,
};


/**
 错误类型

 - DDPErrorCodeParameterNoCompletion: 参数不完整
 - DDPErrorCodeCreatDownloadTaskFail: 下载失败
 - DDPErrorCodeLoginFail: 登录失败
 - DDPErrorCodeRegisterFail: 注册失败
 - DDPErrorCodeUpdateUserNameFail: 更新用户名失败
 - DDPErrorCodeUpdateUserPasswordFail: 更新用户密码失败
 - DDPErrorCodeBindingFail: 绑定失败
 - DDPErrorCodeObjectExist: 对象存在
 */
typedef NS_ENUM(NSUInteger, DDPErrorCode) {
    DDPErrorCodeParameterNoCompletion = 10000,
    DDPErrorCodeCreatDownloadTaskFail,
    DDPErrorCodeLoginFail,
    DDPErrorCodeRegisterFail,
    DDPErrorCodeUpdateUserNameFail,
    DDPErrorCodeUpdateUserPasswordFail,
    DDPErrorCodeBindingFail,
    DDPErrorCodeObjectExist,
};

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
UIKIT_EXTERN NSString *DDPEpisodeTypeToString(DDPEpisodeType type);

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

@interface DDPMethod : NSObject

/**
 请求路径

 @return 请求路径
 */
+ (NSString *)apiPath;


/**
 新路径

 @return 新路径
 */
+ (NSString *)newApiPath;

@end
