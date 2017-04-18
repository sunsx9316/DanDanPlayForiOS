//
//  Config.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#ifndef Config_h
#define Config_h

typedef NS_ENUM(NSUInteger, DanDanPlayDanmakuType) {
    DanDanPlayDanmakuTypeUnknow,
    DanDanPlayDanmakuTypeOfficial,
    DanDanPlayDanmakuTypeBiliBili,
    DanDanPlayDanmakuTypeAcfun,
    DanDanPlayDanmakuTypeByUser,
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
typedef NS_ENUM(NSUInteger, JHEpisodeType) {
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


#endif /* Config_h */
