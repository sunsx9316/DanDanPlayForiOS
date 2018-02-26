//
//  DDPLinkInfo+DB.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPLinkInfo.h"
#import <WCDB/WCDB.h>

@interface DDPLinkInfo (DB)<WCTTableCoding>

WCDB_PROPERTY(name)
WCDB_PROPERTY(ipAdress)
WCDB_PROPERTY(selectedIpAdress)
WCDB_PROPERTY(port)
WCDB_PROPERTY(currentUser)
WCDB_PROPERTY(saveTime)

@end
