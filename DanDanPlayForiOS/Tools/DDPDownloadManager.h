//
//  DDPDownloadManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPDownloadTaskProtocol.h"

typedef void(^DDPDownloadManagerCompletionAction)(NSError *error);

typedef NS_ENUM(NSUInteger, DDPDownloadTasksChangeType) {
    DDPDownloadTasksChangeTypeAdd,
    DDPDownloadTasksChangeTypeRemove,
};

@protocol DDPDownloadManagerObserver<NSObject>
@optional
- (void)tasksDidChange:(NSArray <id<DDPDownloadTaskProtocol>>*)tasks
                  type:(DDPDownloadTasksChangeType)type
                 error:(NSError *)error;

- (void)tasksDidDownloadCompletion;

@end

@interface DDPDownloadManager : NSObject
+ (instancetype)shareDownloadManager;

@property (strong, nonatomic, readonly) NSArray <id<DDPDownloadTaskProtocol>>*tasks;

- (void)addObserver:(id<DDPDownloadManagerObserver>)observer;
- (void)removeObserver:(id<DDPDownloadManagerObserver>)observer;

- (void)addTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion;
- (void)addTasks:(NSArray <id<DDPDownloadTaskProtocol>>*)tasks completion:(dispatch_block_t)completion;
- (void)removeTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion;
- (void)removeTask:(id<DDPDownloadTaskProtocol>)task force:(BOOL)force completion:(DDPDownloadManagerCompletionAction)completion;

- (void)resumeTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion;
- (void)pauseTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion;

- (void)startObserverTaskInfo;
- (void)stopObserverTaskInfo;

@end
