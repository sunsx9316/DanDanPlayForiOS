//
//  DDPCacheManager+Private.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPCacheManager.h"

@interface DDPCacheManager ()
@property (strong, nonatomic, readonly) NSHashTable *observers;
@property (strong, nonatomic, readonly) NSMutableDictionary <NSNumber *, YYWebImageManager *>*imageManagerDic;
@end
