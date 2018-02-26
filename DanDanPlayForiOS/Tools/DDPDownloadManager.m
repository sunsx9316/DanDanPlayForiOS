//
//  DDPDownloadManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPDownloadManager.h"

@interface DDPDownloadManager ()
@property (strong, nonatomic) NSMutableArray <id<DDPDownloadTaskProtocol>>*mTasks;
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

- (void)addObserver:(id<DDPDownloadManagerObserver>)observer {
    if (observer == nil) return;
    
    [_observers addObject:observer];
}

- (void)removeObserver:(id<DDPDownloadManagerObserver>)observer {
    if (observer == nil) return;
    
    [_observers removeObject:observer];
}

- (void)addTask:(id<DDPDownloadTaskProtocol>)task {
    
}

#pragma mark - 懒加载
- (NSMutableArray<id<DDPDownloadTaskProtocol>> *)mTasks {
    if (_mTasks == nil) {
        
    }
    return _mTasks;
}

@end
