//
//  JHUser.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

typedef NS_ENUM(NSUInteger, JHUserType) {
    JHUserTypeUnknow,
    JHUserTypeWeibo,
    JHUserTypeQQ
};

CG_INLINE NSString *jh_userTypeToString(JHUserType type) {
    if (type == JHUserTypeWeibo) {
        return @"weibo";
    }
    
    if (type == JHUserTypeQQ) {
        return @"qq";
    }
    
    return @"";
};

@interface JHUser : JHBase
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSURL *icoImgURL;
@property (assign, nonatomic) JHUserType userType;
@end
