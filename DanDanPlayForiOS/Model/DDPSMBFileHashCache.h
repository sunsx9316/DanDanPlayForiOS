//
//  DDPSMBFileHashCache.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/21.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPSMBFileHashCache : DDPBase

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *md5;
@property (strong, nonatomic) NSDate *date;
@end
