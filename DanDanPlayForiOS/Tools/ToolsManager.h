//
//  ToolsManager.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/8/16.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoModel.h"
#import "JhUser.h"

static inline NSString *danmakuTypeToString(DanDanPlayDanmakuType type) {
    switch (type) {
        case DanDanPlayDanmakuTypeAcfun:
            return @"acfun";
        case DanDanPlayDanmakuTypeBiliBili:
            return @"bilibili";
        case DanDanPlayDanmakuTypeOfficial:
            return @"official";
        default:
            break;
    }
    return @"";
}

static inline DanDanPlayDanmakuType danmakuStringToType(NSString *string) {
    if ([string isEqualToString: @"acfun"]) {
        return DanDanPlayDanmakuTypeAcfun;
    }
    else if ([string isEqualToString: @"bilibili"]) {
        return DanDanPlayDanmakuTypeBiliBili;
    }
    else if ([string isEqualToString: @"official"]) {
        return DanDanPlayDanmakuTypeOfficial;
    }
    return DanDanPlayDanmakuTypeUnknow;
}

typedef void(^getSnapshotAction)(UIImage *image);
typedef void(^getVideosAction)(NSArray <VideoModel *>*videos);

@class HTTPServer;
@interface ToolsManager : NSObject

+ (instancetype)shareToolsManager;

+ (HTTPServer *)shareHTTPServer;

/**
 获取视频的截图

 @param model 视频模型
 @param completion 回调
 */
- (void)videoSnapShotWithModel:(VideoModel *)model completion:(getSnapshotAction)completion;

/**
 扫描视频模型
 */
- (void)startDiscovererVideoWithPath:(NSString *)path completion:(getVideosAction)completion;


/**
 *  获取b站视频av号 分集
 *
 *  @param path       路径
 *  @param completion 回调
 */
+ (void)bilibiliAidWithPath:(NSString *)path complectionHandler:(void(^)(NSString *aid, NSString *page))completion;
/**
 *  获取a站av号 分集
 *
 *  @param path url
 *
 *  @return av号 分集
 */
+ (void)acfunAidWithPath:(NSString *)path complectionHandler:(void(^)(NSString *aid, NSString *index))completion;
@end
