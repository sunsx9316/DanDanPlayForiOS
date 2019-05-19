//
//  DDPDanmakuProducer.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/4/21.
//  Copyright © 2019 JimHuang. All rights reserved.
//  生产者

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JHBaseDanmaku;
@interface DDPDanmakuProducer : NSObject

- (instancetype)initWithDamakus:(NSDictionary <NSNumber *, NSArray <JHBaseDanmaku *>*>*)damakus;

- (void)reloadDataWithTime:(NSInteger)time;
- (NSArray <JHBaseDanmaku *>*)damakusAtTime:(NSInteger)time;

@end

NS_ASSUME_NONNULL_END
