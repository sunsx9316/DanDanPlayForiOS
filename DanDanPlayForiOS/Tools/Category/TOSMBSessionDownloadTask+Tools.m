//
//  TOSMBSessionDownloadTask+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "TOSMBSessionDownloadTask+Tools.h"

@implementation TOSMBSessionDownloadTask (Tools)

- (NSString *)ddp_id {
    return [self.sourceFilePath md5String];
}

- (CGFloat)ddp_progress {
    return self.countOfBytesReceived * 1.0 / self.countOfBytesExpectedToReceive;
}

- (NSString *)ddp_name {
    return self.sourceFilePath.lastPathComponent;
}

- (DDPDownloadTaskState)ddp_state {
    switch (self.state) {
        case TOSMBSessionTaskStateReady:
            return DDPDownloadTaskStateReady;
        case TOSMBSessionTaskStateCancelled:
            return DDPDownloadTaskStateCancelled;
        case TOSMBSessionTaskStateCompleted:
            return DDPDownloadTaskStateCompleted;
        case TOSMBSessionTaskStateFailed:
            return DDPDownloadTaskStateFailed;
        case TOSMBSessionTaskStateRunning:
            return DDPDownloadTaskStateRunning;
        case TOSMBSessionTaskStateSuspended:
            return DDPDownloadTaskStateSuspended;
        default:
            break;
    }
}

- (void)ddp_resumeWithCompletion:(DDPDownloadTaskCompletionAction)completion {
    [self resume];
    if (completion) {
        completion(nil);
    }
}

- (void)ddp_suspendWithCompletion:(DDPDownloadTaskCompletionAction)completion {
    [self suspend];
    if (completion) {
        completion(nil);
    }
}

- (void)ddp_cancelWithForce:(BOOL)force completion:(DDPDownloadTaskCompletionAction)completion {
    [self cancel];
    if (completion) {
        completion(nil);
    }
}

@end
