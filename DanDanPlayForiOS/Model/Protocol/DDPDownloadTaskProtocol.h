//
//  DDPDownloadTask.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DDPDownloadTaskCompletionAction)(NSError *error);

typedef NS_ENUM(NSUInteger, DDPDownloadTaskState) {
    DDPDownloadTaskStateReady,
    DDPDownloadTaskStateRunning,
    DDPDownloadTaskStateSuspended,
    DDPDownloadTaskStateCancelled,
    DDPDownloadTaskStateCompleted,
    DDPDownloadTaskStateFailed
};

@protocol DDPDownloadTaskProtocol <NSObject>

@property (copy, nonatomic, readonly) NSString *ddp_id;

@property (assign, nonatomic, readonly) CGFloat ddp_progress;
@property (copy, nonatomic, readonly) NSString *ddp_name;

@property (assign, readonly) DDPDownloadTaskState ddp_state;

- (void)ddp_resumeWithCompletion:(DDPDownloadTaskCompletionAction)completion;
- (void)ddp_suspendWithCompletion:(DDPDownloadTaskCompletionAction)completion;
- (void)ddp_cancelWithForce:(BOOL)force
                 completion:(DDPDownloadTaskCompletionAction)completion;

@end
