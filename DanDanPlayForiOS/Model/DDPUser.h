//
//  DDPUser.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import <UIKit/UIKit.h>

typedef NSString* DDPUserLoginType;


FOUNDATION_EXPORT DDPUserLoginType DDPUserLoginTypeWeibo;
FOUNDATION_EXPORT DDPUserLoginType DDPUserLoginTypeQQ;
FOUNDATION_EXPORT DDPUserLoginType DDPUserLoginTypeDefault;

@interface DDPUser : DDPBase

/*
 
 name -> screenName
 identity -> userId
 */

/**
 字符串形式的JWT token。将来调用需要验证权限的接口时，需要在HTTP Authorization头中设置“Bearer token”。
 */
@property (copy, nonatomic) NSString *JWTToken;


/**
 旧API中使用的数字形式的token，仅为兼容性设置，不要在新代码中使用此属性
 */
@property (copy, nonatomic) NSString *legacyTokenNumber;

/**
 JWT token过期时间，默认为21天。如果是APP应用开发者账号使用自己的应用登录则为1年。
 */
@property (copy, nonatomic) NSString *tokenExpireTime;

/**
 头像图片的地址
 */
@property (strong, nonatomic) NSURL *iconImgURL;

/**
 用户注册来源类型
 */
@property (copy, nonatomic) DDPUserLoginType userType;

/**
 该用户是否需要先注册弹弹play账号才可正常登录。当此值为true时表示用户使用了QQ微博等第三方登录但没有注册弹弹play账号。
 */
@property (assign, nonatomic) BOOL registerRequired;

/**
 弹弹play用户名。如果用户使用第三方账号登录（如QQ微博）且没有关联弹弹play账号，此属性将为null
 */
@property (copy, nonatomic) NSString *account;

/**
 密码
 */
@property (copy, nonatomic) NSString *password;


/**
 当前用户是否登录
 */
@property (assign, nonatomic, readonly) BOOL isLogin;


/**
 上次操作时间 在登录和退出登录会更新
 */
@property (assign, nonatomic, readonly) NSTimeInterval lastUpdateTime;


/**
 第三方网站的用户id标识，例如qq的openId、微博的uid 用于第三方通过touch id 登录
 */
@property (copy, nonatomic) NSString *thirdPartyUserId;

/**
 更新登录状态

 @param isLogin 登录状态
 */
- (void)updateLoginStatus:(BOOL)isLogin;

@end
