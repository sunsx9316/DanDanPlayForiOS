//
//  JHUser.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JHUserType) {
    JHUserTypeUnknow,
    JHUserTypeWeibo,
    JHUserTypeQQ,
    JHUserTypeDefault
};

CG_INLINE NSString *jh_userTypeToString(JHUserType type) {
    if (type == JHUserTypeWeibo) {
        return @"weibo";
    }
    
    if (type == JHUserTypeQQ) {
        return @"qq";
    }
    
    if (type == JHUserTypeDefault) {
        return @"dandanplay";
    }
    
    return @"";
};

CG_INLINE JHUserType jh_userTypeStringToEnum(NSString *str) {
    if ([str isKindOfClass:[NSString class]]) {
        if ([str isEqualToString:@"weibo"]) {
            return JHUserTypeWeibo;
        }
        
        if ([str isEqualToString:@"qq"]) {
            return JHUserTypeQQ;
        }
        
        if ([str isEqualToString:@"dandanplay"]) {
            return JHUserTypeDefault;
        }        
    }
    
    
    return JHUserTypeUnknow;
};

UIKIT_EXTERN NSString *jh_encryption(NSString *text);
UIKIT_EXTERN NSString *jh_decryption(NSString *text);

@interface JHUser : JHBase
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSURL *icoImgURL;
@property (assign, nonatomic) JHUserType userType;

/**
 是否关联第三方帐号
 */
@property (assign, nonatomic) BOOL registerRequired;

/**
 是否登录成功
 */
@property (assign, nonatomic) BOOL needLogin;

@property (copy, nonatomic) NSString *account;
@property (copy, nonatomic) NSString *password;
@property (assign, nonatomic) JHUserType loginUserType;
@end
