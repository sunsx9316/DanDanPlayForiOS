//
//  DDPSharedNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/4/15.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPSharedNetManager : DDPBaseNetManager

@property (strong, nonatomic, class, readonly) DDPSharedNetManager *sharedNetManager;

- (void)resetJWTToken:(NSString * _Nullable)token;

@end

NS_ASSUME_NONNULL_END
