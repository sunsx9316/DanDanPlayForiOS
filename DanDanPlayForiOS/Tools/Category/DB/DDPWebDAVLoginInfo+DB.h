//
//  DDPWebDAVLoginInfo+DB.h
//  DDPlay
//
//  Created by JimHuang on 2020/6/7.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVLoginInfo.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPWebDAVLoginInfo (DB)<WCTTableCoding>

WCDB_PROPERTY(userName)
WCDB_PROPERTY(userPassword)
WCDB_PROPERTY(path)

@end

NS_ASSUME_NONNULL_END
