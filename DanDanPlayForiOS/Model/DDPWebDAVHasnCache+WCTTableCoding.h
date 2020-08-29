//
//  DDPWebDAVHasnCache+WCTTableCoding.h
//  DDPlay
//
//  Created by JimHuang on 2020/6/9.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVHasnCache.h"
#import <WCDB/WCDB.h>

@interface DDPWebDAVHasnCache (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(key)
WCDB_PROPERTY(md5)
WCDB_PROPERTY(date)

@end
