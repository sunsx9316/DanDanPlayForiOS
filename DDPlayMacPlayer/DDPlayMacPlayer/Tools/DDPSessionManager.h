//
//  DDPSessionManager.h
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/28.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDPShare/DDPMessageModel.h>

NS_ASSUME_NONNULL_BEGIN
@class DDPSessionManager;

@protocol DDPSessionManagerObserver <NSObject>
@optional
- (void)dispatchManager:(DDPSessionManager *)manager didReceiveMessage:(DDPMessageModel *)message;

@end

@interface DDPSessionManager : NSObject

@property (strong, nonatomic, class, readonly) DDPSessionManager *sharedManager;

- (void)addObserver:(id<DDPSessionManagerObserver>)observer;
- (void)removeObserver:(id<DDPSessionManagerObserver>)observer;

- (void)sendMessage:(DDPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
