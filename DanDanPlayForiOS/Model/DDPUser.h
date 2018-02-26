//
//  DDPUser.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DDPUserType) {
    DDPUserTypeUnknow,
    DDPUserTypeWeibo,
    DDPUserTypeQQ,
    DDPUserTypeDefault
};

CG_INLINE NSString *ddp_userTypeToString(DDPUserType type) {
    if (type == DDPUserTypeWeibo) {
        return @"weibo";
    }
    
    if (type == DDPUserTypeQQ) {
        return @"qq";
    }
    
    if (type == DDPUserTypeDefault) {
        return @"dandanplay";
    }
    
    return @"";
};

CG_INLINE DDPUserType ddp_userTypeStringToEnum(NSString *str) {
    if ([str isKindOfClass:[NSString class]]) {
        if ([str isEqualToString:@"weibo"]) {
            return DDPUserTypeWeibo;
        }
        
        if ([str isEqualToString:@"qq"]) {
            return DDPUserTypeQQ;
        }
        
        if ([str isEqualToString:@"dandanplay"]) {
            return DDPUserTypeDefault;
        }        
    }
    
    
    return DDPUserTypeUnknow;
};

@interface DDPUser : DDPBase
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSURL *icoImgURL;
@property (assign, nonatomic) DDPUserType userType;

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
@property (assign, nonatomic) DDPUserType loginUserType;
@end
