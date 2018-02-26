//
//  DDPLinkInfo+DB.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPLinkInfo+DB.h"

@implementation DDPLinkInfo (DB)

WCDB_IMPLEMENTATION(DDPLinkInfo)
WCDB_SYNTHESIZE(DDPLinkInfo, name)
WCDB_SYNTHESIZE(DDPLinkInfo, ipAdress)
WCDB_SYNTHESIZE(DDPLinkInfo, selectedIpAdress)
WCDB_SYNTHESIZE(DDPLinkInfo, port)
WCDB_SYNTHESIZE(DDPLinkInfo, currentUser)
WCDB_SYNTHESIZE(DDPLinkInfo, saveTime)

WCDB_PRIMARY(DDPLinkInfo, selectedIpAdress)

@end
