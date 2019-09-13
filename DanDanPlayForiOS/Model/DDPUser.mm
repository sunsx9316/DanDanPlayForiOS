//
//  DDPUser.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPUser.h"
#import "DDPCacheManager+DB.h"

#import <WCDB/WCDB.h>
#import "DDPUser+WCTTableCoding.h"

DDPUserLoginType DDPUserLoginTypeWeibo = @"weibo";
DDPUserLoginType DDPUserLoginTypeQQ = @"qq";
DDPUserLoginType DDPUserLoginTypeDefault = @"dandanplay";

@interface DDPUser ()
@property (assign, nonatomic) NSTimeInterval lastUpdateTime;
@property (assign, nonatomic) BOOL isLogin;
@end

@implementation DDPUser

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
        return @{@"name" : @"screenName",
                 @"identity" : @"userId",
                 @"iconImgURL" : @"profileImage",
                 @"account" : @"userName",
                 @"JWTToken" : @"token"
                 };
}

- (void)updateLoginStatus:(BOOL)isLogin {
    _isLogin = isLogin;
    self.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    if (self.identity == [DDPCacheManager shareCacheManager].currentUser.identity) {
        [DDPCacheManager shareCacheManager].currentUser = self;        
    }
}

WCDB_IMPLEMENTATION(DDPUser)
WCDB_SYNTHESIZE(DDPUser, name)
WCDB_SYNTHESIZE(DDPUser, identity)
WCDB_SYNTHESIZE(DDPUser, JWTToken)
WCDB_SYNTHESIZE(DDPUser, tokenExpireTime)
WCDB_SYNTHESIZE(DDPUser, iconImgURL)
WCDB_SYNTHESIZE(DDPUser, userType)
WCDB_SYNTHESIZE(DDPUser, registerRequired)
WCDB_SYNTHESIZE(DDPUser, account)
WCDB_SYNTHESIZE(DDPUser, password)
WCDB_SYNTHESIZE(DDPUser, isLogin)
WCDB_SYNTHESIZE(DDPUser, lastUpdateTime)
WCDB_SYNTHESIZE(DDPUser, legacyTokenNumber)
WCDB_SYNTHESIZE(DDPUser, thirdPartyUserId)

WCDB_PRIMARY(DDPUser, identity)

@end
