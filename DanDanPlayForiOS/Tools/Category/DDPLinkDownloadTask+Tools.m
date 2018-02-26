//
//  DDPLinkDownloadTask+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPLinkDownloadTask+Tools.h"
#import "DDPLinkNetManagerOperation.h"

@implementation DDPLinkDownloadTask (Tools)

- (NSString *)ddp_id {
    return self.taskId;
}

- (CGFloat)ddp_progress {
    return self.progress;
}

- (NSString *)ddp_name {
    return self.name;
}

/**
 下载状态：0-已停止，1-已暂停，2-正在下载，3-正在做种，4-正在计算Hash，
 5-正在停止，6-出错，7-正在获取元数据
 */
- (DDPDownloadTaskState)ddp_state {
    switch (self.state) {
        case DDPLinkDownloadTaskStateGetMetaData:
        case DDPLinkDownloadTaskStateCalculateHash:
            return DDPDownloadTaskStateReady;
        case DDPLinkDownloadTaskStateStop:
        case DDPLinkDownloadTaskStateStoping:
            return DDPDownloadTaskStateCancelled;
        case DDPLinkDownloadTaskStateMaskTorrent:
            return DDPDownloadTaskStateCompleted;
        case DDPLinkDownloadTaskStateError:
            return DDPDownloadTaskStateFailed;
        case DDPLinkDownloadTaskStateDownloading:
            return DDPDownloadTaskStateRunning;
        case DDPLinkDownloadTaskStatePause:
            return DDPDownloadTaskStateSuspended;
        default:
            break;
    }
}

- (void)ddp_resumeWithCompletion:(DDPDownloadTaskCompletionAction)completion {
    [DDPLinkNetManagerOperation linkControlDownloadWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress taskId:self.taskId method:JHControlLinkTaskMethodStart forceDelete:NO completionHandler:^(DDPLinkDownloadTask *model, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)ddp_suspendWithCompletion:(DDPDownloadTaskCompletionAction)completion {
    [DDPLinkNetManagerOperation linkControlDownloadWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress taskId:self.taskId method:JHControlLinkTaskMethodPause forceDelete:NO completionHandler:^(DDPLinkDownloadTask *model, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)ddp_cancelWithForce:(BOOL)force
                 completion:(DDPDownloadTaskCompletionAction)completion {
    [DDPLinkNetManagerOperation linkControlDownloadWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress taskId:self.taskId method:JHControlLinkTaskMethodDelete forceDelete:force completionHandler:^(DDPLinkDownloadTask *model, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end
