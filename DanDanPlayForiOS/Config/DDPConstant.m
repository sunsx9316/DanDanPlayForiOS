//
//  DDPConstant.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/11/18.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPConstant.h"
#import "DDPMacroDefinition.h"

DDPProductionType DDPProductionTypeTVSeries = @"tvseries";
DDPProductionType DDPProductionTypeTVSpecial = @"tvspecial";
DDPProductionType DDPProductionTypeOVA = @"ova";
DDPProductionType DDPProductionTypeMovie = @"movie";
DDPProductionType DDPProductionTypeMusicVideo = @"musicvideo";
DDPProductionType DDPProductionTypeWeb = @"web";
DDPProductionType DDPProductionTypeOther = @"other";
DDPProductionType DDPProductionTypeMusicJPMovie = @"jpmovie";
DDPProductionType DDPProductionTypeMusicJPDrama = @"jpdrama";
DDPProductionType DDPProductionTypeMusicUnknown = @"unknown";

DDPLogModule DDPLogModuleHomePage = "首页";
DDPLogModule DDPLogModuleNetwork = "网络";
DDPLogModule DDPLogModuleLogin = "登录";
DDPLogModule DDPLogModulePlayer = "播放器";
DDPLogModule DDPLogModuleFile = "文件";
DDPLogModule DDPLogModuleMine = "我的";
DDPLogModule DDPLogModuleOther = "其它";

#if DDPAPPTYPE == 1
DDPAppType ddp_appType = DDPAppTypeReview;
#elif DDPAPPTYPEISMAC
DDPAppType ddp_appType = DDPAppTypeToMac;
#else
DDPAppType ddp_appType = DDPAppTypeDefault;
#endif

#ifdef BUGLY_KEY
NSString *ddp_buglyKey = BUGLY_KEY;
#else
NSString *ddp_buglyKey = @"";
#endif

#ifdef UM_SHARE_KEY
NSString *ddp_UMShareKey = UM_SHARE_KEY;
#else
NSString *ddp_UMShareKey = @"";
#endif

#ifdef QQ_APP_KEY
NSString *ddp_QQAppKey = QQ_APP_KEY;
#else
NSString *ddp_QQAppKey = @"";
#endif

#ifdef WEIBO_APP_KEY
NSString *ddp_weiboAppKey = WEIBO_APP_KEY;
#else
NSString *ddp_weiboAppKey = @"";
#endif

#ifdef WEIBO_APP_SECRET
NSString *ddp_weiboSecretKey = WEIBO_APP_SECRET;
#else
NSString *ddp_weiboSecretKey = @"";
#endif

#ifdef API_V2_APP_ID
NSString *ddp_apiV2AppId = API_V2_APP_ID;
#else
NSString *ddp_apiV2AppId = @"";
#endif

#ifdef API_V2_APP_SECRET
NSString *ddp_apiV2AppSecret = API_V2_APP_SECRET;
#else
NSString *ddp_apiV2AppSecret = @"";
#endif

#ifdef WEIBO_REDIRECT_URL
NSString *ddp_weiboRedirectURL = WEIBO_REDIRECT_URL;
#else
NSString *ddp_weiboRedirectURL = @"";
#endif

@implementation DDPConstant

@end
