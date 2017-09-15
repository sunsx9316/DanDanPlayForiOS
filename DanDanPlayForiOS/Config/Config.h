//
//  Config.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MacroDefinition.h"

#ifndef Config_h
#define Config_h

/**
 弹幕类型

 - DanDanPlayDanmakuTypeUnknow: 未知类型
 - DanDanPlayDanmakuTypeOfficial: 官方弹幕
 - DanDanPlayDanmakuTypeBiliBili: b站弹幕
 - DanDanPlayDanmakuTypeAcfun: a站弹幕
 - DanDanPlayDanmakuTypeByUser: 用户发送的弹幕
 */
typedef NS_ENUM(NSUInteger, DanDanPlayDanmakuType) {
    DanDanPlayDanmakuTypeUnknow = 1 << 0,
    DanDanPlayDanmakuTypeOfficial = 1 << 1,
    DanDanPlayDanmakuTypeBiliBili = 1 << 2,
    DanDanPlayDanmakuTypeAcfun = 1 << 3,
    DanDanPlayDanmakuTypeByUser = 1 << 4,
};


/**
 节目类型

 - JHEpisodeTypeAnimate: TV动画
 - JHEpisodeTypeAnimateSpecial: TV动画特别放送
 - JHEpisodeTypeOVA: OVA
 - JHEpisodeTypePalgantong: 剧场版
 - JHEpisodeTypeMV: 音乐视频（MV）
 - JHEpisodeTypeWeb: 网络放送
 - JHEpisodeTypeOther: 其他分类
 - JHEpisodeTypeThreeDMovie: 三次元电影
 - JHEpisodeTypeThreeDTVPlayOrChineseAnimate: 三次元电视剧或国产动画
 - JHEpisodeTypeUnknow: 未知（尚未分类）
 */
typedef NS_ENUM(NSInteger, JHEpisodeType) {
    JHEpisodeTypeAnimate = 1,
    JHEpisodeTypeAnimateSpecial,
    JHEpisodeTypeOVA,
    JHEpisodeTypePalgantong,
    JHEpisodeTypeMV,
    JHEpisodeTypeWeb,
    JHEpisodeTypeOther,
    JHEpisodeTypeThreeDMovie = 10,
    JHEpisodeTypeThreeDTVPlayOrChineseAnimate = 20,
    JHEpisodeTypeUnknow = 99,
};

CG_INLINE NSString *jh_episodeTypeToString(JHEpisodeType type) {
    switch (type) {
        case JHEpisodeTypeAnimate:
            return @"TV动画";
        case JHEpisodeTypeAnimateSpecial:
            return @"TV动画特别放送";
        case JHEpisodeTypeOVA:
            return @"OVA";
        case JHEpisodeTypePalgantong:
            return @"剧场版";
        case JHEpisodeTypeMV:
            return @"音乐视频（MV）";
        case JHEpisodeTypeWeb:
            return @"网络放送";
        case JHEpisodeTypeOther:
            return @"其他";
        case JHEpisodeTypeThreeDMovie:
            return @"三次元电影";
        case JHEpisodeTypeThreeDTVPlayOrChineseAnimate:
            return @"三次元电视剧或国产动画";
        case JHEpisodeTypeUnknow:
            return @"未知";
        default:
            break;
    }
};

CG_INLINE float jh_systemVersion() {
    return [UIDevice currentDevice].systemVersion.floatValue;
};

CG_INLINE BOOL jh_isPad() {
    return [UIDevice currentDevice].isPad;
};

CG_INLINE NSString *jh_subtitleDownloadPath() {
    NSString *path = [[UIApplication sharedApplication].documentsPath stringByAppendingPathComponent:@"subtitle"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

CG_INLINE NSString *jh_danmakuDownloadPath() {
    NSString *path = [[UIApplication sharedApplication].documentsPath stringByAppendingPathComponent:@"danmaku"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

CG_INLINE NSURL *jh_linkImageURL(NSString *ip, NSString *hash) {
    if (hash.length == 0) return nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/image/%@", ip, LINK_API_INDEX, hash]];
}

#endif /* Config_h */
