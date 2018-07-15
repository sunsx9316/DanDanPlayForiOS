//
//  NSString+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/25.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tools)
+ (NSString *)getIPAddress;

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

/**
 判断当前路径是不是视频的字幕路径

 @param videoPath 视频路径
 @return 是不是视频的字幕路径
 */
- (BOOL)isSubtileFileWithVideoPath:(NSString *)videoPath;

/**
 判断当前路径是不是视频的弹幕路径

 @param videoPath 视频路径
 @return 是不是视频的弹幕路径
 */
- (BOOL)isDanmakuFileWithVideoPath:(NSString *)videoPath;

/**
 字符串是否为ip

 @return 是否为ip
 */
- (BOOL)isIpAdress;

/**
 汉字转拼音首字母

 @return 拼音首字母
 */
- (NSString *)pinYinIndex;

/**
 格式化数字

 @param upper 上界
 @param number 数字
 @return 格式化数字
 */
+ (NSString *)numberFormatterWithUpper:(NSUInteger)upper
                                number:(NSUInteger)number;

- (BOOL)isRightAccount;
- (BOOL)isRightPassword;
- (BOOL)isRightEmail;
- (BOOL)isRightNickName;

/**
 字符串是否为磁力链

 @return 是否为磁力链
 */
- (BOOL)isMagnet;

- (NSString *)ddp_appendingPathComponent:(NSString *)str;

@end
