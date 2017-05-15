//
//  MacroDefinition.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#ifndef MacroDefinition_h
#define MacroDefinition_h

//#ifdef DEBUG
//#define API_DOMAIN @"http://acplay.net/api/"
//#define API_VERSION @"v1"
//
//#define API_PATH [NSString stringWithFormat:@"%@%@", API_DOMAIN, API_VERSION]
//
//#else

#define API_DOMAIN @"https://api.acplay.net/api/"
#define API_VERSION @"v1"

#define API_PATH [NSString stringWithFormat:@"%@%@", API_DOMAIN, API_VERSION]

//#endif

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

//屏幕宽高
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

//其它
#define SEARCH_BAR_HEIRHT 44

//导航栏
//设置成自定义颜色
#define SET_NAV_BAR_COLOR(color, isTranslucent) self.navigationController.navigationBar.barTintColor = color;\
[self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];\
self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];\
self.navigationController.navigationBar.translucent = isTranslucent;
//设置成默认样式
#define SET_NAV_BAR_DEFAULT SET_NAV_BAR_COLOR(MAIN_COLOR, NO)
//透明
#define SET_NAVIGATION_BAR_CLEAR SET_NAV_BAR_COLOR([UIColor whiteColor], YES)


//YYWebImage 默认加载方法
#define YY_WEB_IMAGE_DEFAULT_OPTION YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation

#define COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE @"copy_file_at_other_app_success"
#define WRITE_FILE_SUCCESS_NOTICE @"write_file_success"

#define APP_LINK @"itms-apps://itunes.apple.com/app/id1189757764"

#endif /* MacroDefinition_h */
