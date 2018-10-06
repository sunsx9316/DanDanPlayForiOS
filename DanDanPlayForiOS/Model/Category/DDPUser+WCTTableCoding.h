//
//  DDPUser+WCTTableCoding.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPUser.h"
#import <WCDB/WCDB.h>

@interface DDPUser (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(name)
WCDB_PROPERTY(identity)
WCDB_PROPERTY(JWTToken)
WCDB_PROPERTY(tokenExpireTime)
WCDB_PROPERTY(iconImgURL)
WCDB_PROPERTY(userType)
WCDB_PROPERTY(registerRequired)
WCDB_PROPERTY(account)
WCDB_PROPERTY(password)
WCDB_PROPERTY(isLogin)
WCDB_PROPERTY(lastUpdateTime)
WCDB_PROPERTY(legacyTokenNumber)
WCDB_PROPERTY(thirdPartyUserId)


@end
