//
//  DDPMacroDefinition.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "APPKey.h"
#import "LogUtil.h"

#ifndef DDPMacroDefinition_h
#define DDPMacroDefinition_h

#ifdef DEBUG

#else
#define NSLog(format, ...)
#endif

#if defined(__cplusplus)
#define let auto const
#define var auto
#else
#define let const __auto_type
#define var __auto_type
#endif

#if DEBUG
#define DDP_KEYPATH(object, property) ((void)(NO && ((void)object.property, NO)), @ #property)
#else
#define DDP_KEYPATH(object, property) @ #property
#endif

typedef struct __attribute__((objc_boxable)) CGPoint CGPoint;
typedef struct __attribute__((objc_boxable)) CGSize CGSize;
typedef struct __attribute__((objc_boxable)) CGRect CGRect;
typedef struct __attribute__((objc_boxable)) CGVector CGVector;
typedef struct __attribute__((objc_boxable)) CGAffineTransform CGAffineTransform;
typedef struct __attribute__((objc_boxable)) UIEdgeInsets UIEdgeInsets;
typedef struct __attribute__((objc_boxable)) _NSRange NSRange;


//#define API_DOMAIN @"https://api.acplay.net"
//#define API_INDEX @"api/v1"
//#define [DDPMethod apiPath] [NSString stringWithFormat:@"%@/%@", API_DOMAIN, API_INDEX]

//连接PC的api路径
#define LINK_API_INDEX @"api/v1"

//动漫花园解析url
#define API_DMHY_DOMAIN @"http://res.acplay.net"

//屏幕宽高
#define DDP_WIDTH [UIScreen mainScreen].bounds.size.width
#define DDP_HEIGHT [UIScreen mainScreen].bounds.size.height

//其它
#define SEARCH_BAR_HEIRHT 30

//默认黑色通明度
#define DEFAULT_BLACK_ALPHA 0.45

#define USER_ACCOUNT_MIN_COUNT 5
#define USER_ACCOUNT_MAX_COUNT 20
#define USER_PASSWORD_MIN_COUNT 5
#define USER_PASSWORD_MAX_COUNT 20
#define USER_NAME_MAX_COUNT 50

//YYWebImage 默认加载方法
#define YY_WEB_IMAGE_DEFAULT_OPTION YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation

//通知文件列表刷新
#define COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE @"copy_file_at_other_app_success"
#define START_RECEIVE_FILE_NOTICE @"start_receive_file"
#define RECEIVE_FILE_PROGRESS_NOTICE @"receive_file_progress"
#define WRITE_FILE_SUCCESS_NOTICE @"write_file_success"
#define ATTENTION_SUCCESS_NOTICE @"attention_success"
#define ATTENTION_KEY @"attention"
//删除文件
#define DELETE_FILE_SUCCESS_NOTICE @"delete_file_success"
#define MOVE_FILE_SUCCESS_NOTICE @"move_file_success"

#define APP_LINK @"itms-apps://itunes.apple.com/app/id1189757764"

#define CLIENT_ID @"ddplayios"
//windows最小连接的版本
#define WIN_MINI_LINK_VERSION @"6.8.2"
//系统最低支持版本
#define MINI_SUPPORT_VERTSION @"9.0"

//弹弹官网
#define DDPLAY_OFFICIAL_SITE @"http://www.dandanplay.com"

#if DDPAPPTYPE == 2
#define DDPAPPTYPEISMAC 1

#elif DDPAPPTYPE == 1
#define DDPAPPTYPEISREVIEW 1
#elif DDPAPPTYPE == 0
#define DDPAPPTYPEIOS 1
#endif

#endif /* DDPMacroDefinition_h */
