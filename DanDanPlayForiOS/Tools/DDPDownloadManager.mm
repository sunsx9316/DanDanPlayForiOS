//
//  DDPDownloadManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPDownloadManager.h"


#import "DDPLinkDownloadTask+Tools.h"
#import "DDPMethod.h"
#import "DDPLinkNetManagerOperation.h"

#if DDPAPPTYPE != 2
#import "DDPCacheManager+DB.h"
#import "TOSMBSessionDownloadTask+DB.h"
#endif

@interface DDPDownloadManager ()<TOSMBSessionDownloadTaskDelegate>
@property (strong, nonatomic) NSMutableArray <id<DDPDownloadTaskProtocol>>*mTasks;
@property (strong, nonatomic) NSArray <DDPLinkDownloadTask *>*linkDownloadTasks;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DDPDownloadManager
{
    NSHashTable *_observers;
}

+ (instancetype)shareDownloadManager {
    static dispatch_once_t onceToken;
    static DDPDownloadManager *_manager;
    dispatch_once(&onceToken, ^{
        _manager = [[DDPDownloadManager alloc] init];
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    }
    return self;
}

- (NSArray<id<DDPDownloadTaskProtocol>> *)tasks {
    if (self.linkDownloadTasks.count > 0) {
        if (self.mTasks) {
            return [self.mTasks arrayByAddingObjectsFromArray:self.linkDownloadTasks];
        }
        return self.linkDownloadTasks;
    }
    return self.mTasks;
}

- (void)addObserver:(id<DDPDownloadManagerObserver>)observer {
    if (observer == nil) return;
    
    [_observers addObject:observer];
}

- (void)removeObserver:(id<DDPDownloadManagerObserver>)observer {
    if (observer == nil) return;
    
    [_observers removeObject:observer];
}

#if DDPAPPTYPEISMAC
- (void)addTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion {
    
}

- (void)addTasks:(NSArray<id<DDPDownloadTaskProtocol>> *)tasks completion:(dispatch_block_t)completion {
    
}

- (void)removeTask:(NSObject <DDPDownloadTaskProtocol>*)task force:(BOOL)force completion:(DDPDownloadManagerCompletionAction)completion {
    
}

- (void)removeTasks:(NSArray <NSObject <DDPDownloadTaskProtocol>*>*)tasks force:(BOOL)force completion:(DDPDownloadManagerTasksCompletionAction)completion {
    
}

- (void)addTask:(NSObject <DDPDownloadTaskProtocol>*)task
     autoNotice:(BOOL)autoNotice
     completion:(DDPDownloadManagerCompletionAction)completion {
    
}

#else

- (void)addTask:(NSObject <DDPDownloadTaskProtocol, WCTTableCoding>*)task completion:(DDPDownloadManagerCompletionAction)completion {
    if (task == nil) {
        if (completion) {
            completion(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        
        return;
    }
    
    @weakify(self)
    [self addTask:task autoNotice:YES completion:^(NSError *error) {
        @strongify(self)
        if (!self) return;
        
        for (id<DDPDownloadManagerObserver>obj in self->_observers.copy) {
            if ([obj respondsToSelector:@selector(tasksDidChange:type:error:)]) {
                [obj tasksDidChange:@[task] type:DDPDownloadTasksChangeTypeAdd error:error];
            }
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)addTasks:(NSArray <NSObject <DDPDownloadTaskProtocol, WCTTableCoding>*>*)tasks completion:(dispatch_block_t)completion {
    if (tasks.count == 0) {
        return;
    }
    
    dispatch_group_t _group = dispatch_group_create();
    
    dispatch_queue_t _queue = dispatch_queue_create("com.dandanplay.creat.group", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(_group, _queue, ^{
        
        [tasks enumerateObjectsUsingBlock:^(NSObject<DDPDownloadTaskProtocol, WCTTableCoding> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_enter(_group);
            
            [self addTask:obj autoNotice:NO completion:^(NSError *error) {
                dispatch_group_leave(_group);
            }];
        }];
    });
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
        
        for (id<DDPDownloadManagerObserver>obj in _observers.copy) {
            if ([obj respondsToSelector:@selector(tasksDidChange:type:error:)]) {
                [obj tasksDidChange:tasks type:DDPDownloadTasksChangeTypeAdd error:nil];
            }
        }
    });
}

- (void)removeTask:(NSObject <DDPDownloadTaskProtocol>*)task force:(BOOL)force completion:(DDPDownloadManagerCompletionAction)completion {
    if (task == nil) {
        if (completion) {
            completion(DDPErrorWithCode(DDPErrorCodeCreatDownloadTaskFail));
        }
        return;
    }
    
    [task ddp_cancelWithForce:force completion:^(NSError *error) {
        if (error == nil) {
            if ([task isKindOfClass:[TOSMBSessionDownloadTask class]]) {
                [self.mTasks removeObject:task];
                WCTDatabase *db = [DDPCacheManager shareDB];
                [db deleteObjectsFromTable:DDPSMBDownloadTaskCache.className where:DDPSMBDownloadTaskCache.sourceFilePath == task.ddp_id];
            }
        }
        
        for (id<DDPDownloadManagerObserver>obj in _observers.copy) {
            if ([obj respondsToSelector:@selector(tasksDidChange:type:error:)]) {
                [obj tasksDidChange:@[task] type:DDPDownloadTasksChangeTypeRemove error:error];
            }
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)removeTasks:(NSArray <NSObject <DDPDownloadTaskProtocol>*>*)tasks force:(BOOL)force completion:(DDPDownloadManagerTasksCompletionAction)completion {
    if (tasks.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    dispatch_group_t _group = dispatch_group_create();
    
    dispatch_queue_t _queue = dispatch_queue_create("com.dandanplay.creat.group", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(_group, _queue, ^{
        
        [tasks enumerateObjectsUsingBlock:^(NSObject<DDPDownloadTaskProtocol> * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_enter(_group);
            
            [task ddp_cancelWithForce:force completion:^(NSError *error) {
                if (error == nil) {
                    if ([task isKindOfClass:[TOSMBSessionDownloadTask class]]) {
                        [self.mTasks removeObject:task];
                        WCTDatabase *db = [DDPCacheManager shareDB];
                        [db deleteObjectsFromTable:DDPSMBDownloadTaskCache.className where:DDPSMBDownloadTaskCache.sourceFilePath == task.ddp_id];
                    }
                }
                
                dispatch_group_leave(_group);
            }];
        }];
    });
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        for (id<DDPDownloadManagerObserver>obj in _observers.copy) {
            if ([obj respondsToSelector:@selector(tasksDidChange:type:error:)]) {
                [obj tasksDidChange:tasks type:DDPDownloadTasksChangeTypeRemove error:nil];
            }
        }
        
        if (completion) {
            completion();
        }
    });
}

- (void)addTask:(NSObject <DDPDownloadTaskProtocol, WCTTableCoding>*)task
     autoNotice:(BOOL)autoNotice
     completion:(DDPDownloadManagerCompletionAction)completion {
    if (task == nil) {
        if (completion) {
            completion(DDPErrorWithCode(DDPErrorCodeCreatDownloadTaskFail));
        }
        return;
    }
    
    __block BOOL flag = NO;
    [self.tasks enumerateObjectsUsingBlock:^(id<DDPDownloadTaskProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.ddp_id isEqualToString:task.ddp_id]) {
            flag = YES;
            *stop = YES;
        }
    }];
    
    //任务不存在
    if (flag == NO) {
        if ([task isKindOfClass:[TOSMBSessionDownloadTask class]]) {
            TOSMBSessionDownloadTask *aTask = (TOSMBSessionDownloadTask *)task;
            [aTask setValue:self forKey:@"delegate"];
            
            [task ddp_resumeWithCompletion:^(NSError *error) {
                if (error == nil) {
                    [self.mTasks addObject:task];
                    if ([task isKindOfClass:[TOSMBSessionDownloadTask class]]) {
                        WCTDatabase *db = [DDPCacheManager shareDB];
                        [db insertOrReplaceObject:aTask.cache into:DDPSMBDownloadTaskCache.className];
                    }
                }
                
                if (autoNotice) {
                    for (id<DDPDownloadManagerObserver>obj in _observers.copy) {
                        if ([obj respondsToSelector:@selector(tasksDidChange:type:error:)]) {
                            [obj tasksDidChange:@[task] type:DDPDownloadTasksChangeTypeAdd error:error];
                        }
                    }
                }
                
                if (completion) {
                    completion(error);
                }
            }];
        }
        //电脑端下载任务
        else {
            //获取电脑端任务
            [self startObserverTaskInfo];
            if (completion) {
                completion(nil);
            }
        }
    }
    else {
        if (completion) {
            completion(DDPErrorWithCode(DDPErrorCodeObjectExist));
        }
    }
}
#endif


- (void)removeTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion {
    [self removeTask:task force:NO completion:completion];
}

- (void)resumeTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion {
    [task ddp_resumeWithCompletion:completion];
}

- (void)pauseTask:(id<DDPDownloadTaskProtocol>)task completion:(DDPDownloadManagerCompletionAction)completion {
    [task ddp_suspendWithCompletion:completion];
}

- (void)startObserverTaskInfo {
    self.timer.fireDate = [NSDate distantPast];
}

- (void)stopObserverTaskInfo {
    self.timer.fireDate = [NSDate distantFuture];
}

#pragma mark - 私有方法
- (void)timerStart:(NSTimer *)timer {
    [DDPLinkNetManagerOperation linkDownloadListWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress completionHandler:^(DDPLinkDownloadTaskCollection *collection, NSError *error) {
        if (error == nil) {
            [collection.collection enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DDPLinkDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.isDeleted) {
                    [collection.collection removeObjectAtIndex:idx];
                }
            }];
            
            if (self.linkDownloadTasks.count != collection.collection.count) {
                self.linkDownloadTasks = collection.collection;
                for (id<DDPDownloadManagerObserver>obj in _observers.copy) {
                    if ([obj respondsToSelector:@selector(tasksDidChange:type:error:)]) {
                        [obj tasksDidChange:collection.collection type:DDPDownloadTasksChangeTypeUpdate error:nil];
                    }
                }
            }
            else {
                self.linkDownloadTasks = collection.collection;
            }
        }
    }];
}

#pragma mark - TOSMBSessionDownloadTaskDelegate
- (void)downloadTask:(TOSMBSessionDownloadTask *)downloadTask didFinishDownloadingToPath:(NSString *)destinationPath {
    #if DDPAPPTYPE != 2
    if (downloadTask) {
        //移除下载成功的任务
        [self removeTask:downloadTask completion:^(NSError *error) {
            if (error == nil) {
                //刷新本地列表
                [[NSNotificationCenter defaultCenter] postNotificationName:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
            }
        }];
    }
    #endif
    
}

#pragma mark - 懒加载
- (NSMutableArray<id<DDPDownloadTaskProtocol>> *)mTasks {
#if DDPAPPTYPE != 2
    if (_mTasks == nil) {
        WCTDatabase *db = [DDPCacheManager shareDB];
        
        TOSMBSession *session = [DDPToolsManager shareToolsManager].SMBSession;
        if (session) {
            NSArray <DDPSMBDownloadTaskCache *>*taskCaches = [db getAllObjectsOfClass:[DDPSMBDownloadTaskCache class] fromTable:DDPSMBDownloadTaskCache.className];
            
            NSString *downloadPath = ddp_taskDownloadPath();
            NSMutableArray *tasks = [NSMutableArray array];
            [taskCaches enumerateObjectsUsingBlock:^(DDPSMBDownloadTaskCache * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TOSMBSessionDownloadTask *aTask = [session downloadTaskForFileAtPath:obj.sourceFilePath destinationPath:downloadPath delegate:self];
                //设置文件大小
                [aTask setValue:@(obj.countOfBytesExpectedToReceive) forKey:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))];
//                [aTask setValue:@(obj.countOfBytesReceived) forKey:NSStringFromSelector(@selector(countOfBytesReceived))];
                [tasks addObject:aTask];
            }];
            _mTasks = tasks;
        }
    }
#endif
    return _mTasks;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
    }
    return _timer;
}

@end
