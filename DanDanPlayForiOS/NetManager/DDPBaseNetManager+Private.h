//
//  DDPBaseNetManager+Private.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/4/15.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#ifndef DDPBaseNetManager_Private_h
#define DDPBaseNetManager_Private_h

@class AFHTTPSessionManager;

@interface DDPBaseNetManager ()
@property (strong, nonatomic, readonly) AFHTTPSessionManager *HTTPSessionManager;
@end

#endif /* DDPBaseNetManager_Private_h */
