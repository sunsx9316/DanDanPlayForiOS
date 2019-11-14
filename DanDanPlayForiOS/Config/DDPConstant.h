//
//  DDPConstant.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/11/18.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* DDPProductionType;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeTVSeries;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeTVSpecial;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeOVA;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeMovie;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeMusicVideo;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeWeb;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeOther;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeMusicJPMovie;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeMusicJPDrama;
FOUNDATION_EXPORT DDPProductionType DDPProductionTypeMusicUnknown;

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


/**
 当前app类型

 - DDPAppTypeDefault: 默认类型 展示所有功能
 - DDPAppTypeReview: 审核中 隐藏一下功能
 - DDPAppTypeToMac: iOS to Mac版本
 */
typedef NS_ENUM(NSUInteger, DDPAppType) {
    DDPAppTypeDefault,
    DDPAppTypeReview,
    DDPAppTypeToMac,
};

typedef char * DDPLogModule;
FOUNDATION_EXPORT DDPLogModule DDPLogModuleHomePage;
FOUNDATION_EXPORT DDPLogModule DDPLogModuleNetwork;
FOUNDATION_EXPORT DDPLogModule DDPLogModuleLogin;
FOUNDATION_EXPORT DDPLogModule DDPLogModulePlayer;
FOUNDATION_EXPORT DDPLogModule DDPLogModuleFile;
FOUNDATION_EXPORT DDPLogModule DDPLogModuleMine;
FOUNDATION_EXPORT DDPLogModule DDPLogModuleOther;

FOUNDATION_EXPORT DDPAppType ddp_appType;

FOUNDATION_EXPORT NSString *ddp_buglyKey;
FOUNDATION_EXPORT NSString *ddp_UMShareKey;
FOUNDATION_EXPORT NSString *ddp_QQAppKey;
FOUNDATION_EXPORT NSString *ddp_weiboAppKey;
FOUNDATION_EXPORT NSString *ddp_weiboSecretKey;
FOUNDATION_EXPORT NSString *ddp_weiboRedirectURL;
FOUNDATION_EXPORT NSString *ddp_apiV2AppId;
FOUNDATION_EXPORT NSString *ddp_apiV2AppSecret;

@interface DDPConstant : NSObject

@end

NS_ASSUME_NONNULL_END
