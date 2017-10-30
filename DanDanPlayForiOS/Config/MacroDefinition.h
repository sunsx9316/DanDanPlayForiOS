//
//  MacroDefinition.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "APPKey.h"

#ifndef MacroDefinition_h
#define MacroDefinition_h

#ifdef DEBUG
#define NSLog(...) printf("%s\n", [[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#else
#define NSLog(format, ...)
#endif


#define API_DOMAIN @"https://api.acplay.net"
#define API_INDEX @"api/v1"
#define API_PATH [NSString stringWithFormat:@"%@/%@", API_DOMAIN, API_INDEX]

//连接PC的api路径
#define LINK_API_INDEX API_INDEX

//动漫花园解析url
#define API_DMHY_DOMAIN @"https://res.chinacloudsites.cn"


//颜色
#define RGBCOLOR(r,g,b) RGBACOLOR(r,g,b,1)
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//项目主色调
#define MAIN_COLOR RGBCOLOR(51, 151, 252)
#define BACK_GROUND_COLOR [UIColor whiteColor]
#define VERY_LIGHT_GRAY_COLOR RGBCOLOR(240, 240, 240)
#define LIGHT_GRAY_COLOR RGBCOLOR(230, 230, 230)

//字体
#define VERY_SMALL_SIZE_FONT [UIFont systemFontOfSize:11 + 11 * (jh_isPad() * 0.5)]
#define SMALL_SIZE_FONT [UIFont systemFontOfSize:13 + 13 * (jh_isPad() * 0.5)]
#define NORMAL_SIZE_FONT [UIFont systemFontOfSize:15 + 15 * (jh_isPad() * 0.5)]
#define BIG_SIZE_FONT [UIFont systemFontOfSize:17 + 17 * (jh_isPad() * 0.5)]
#define VERY_BIG_SIZE_FONT [UIFont systemFontOfSize:19 + 19 * (jh_isPad() * 0.5)]
#define BLOD_LARGE_SIZE_FONT [UIFont boldSystemFontOfSize:21 + 21 * (jh_isPad() * 0.5)]

//屏幕宽高
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

//其它
#define SEARCH_BAR_HEIRHT 30

#define USER_ACCOUNT_MIN_COUNT 5
#define USER_ACCOUNT_MAX_COUNT 20
#define USER_PASSWORD_MIN_COUNT 5
#define USER_PASSWORD_MAX_COUNT 20
#define USER_NAME_MAX_COUNT 50

//YYWebImage 默认加载方法
#define YY_WEB_IMAGE_DEFAULT_OPTION YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation

//通知文件列表刷新
#define COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE @"copy_file_at_other_app_success"
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


#endif /* MacroDefinition_h */
