//
//  DDPDanmakuFactory.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/4/21.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPDanmakuProducer.h"
#import "DDPDanmakuManager.h"
#import "DDPBaseDanmaku+Tools.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

//在主线程分析弹幕的时间
#define PARSE_TIME 5

@interface DDPDanmakuProducer ()
@property (strong, nonatomic) NSDictionary <NSNumber *, NSArray <JHBaseDanmaku *>*>* danmakusDic;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSNumber *>*filterFlagDic;
@property (strong, nonatomic) NSArray <DDPFilter *>*filterModels;
@end

@implementation DDPDanmakuProducer
{
    dispatch_semaphore_t _lock;
    NSOperationQueue *_queue;
}

- (instancetype)initWithDamakus:(NSDictionary <NSNumber *, NSArray <JHBaseDanmaku *>*>*)damakus {
    if (self = [super init]) {
        _danmakusDic = [damakus copy];
        _lock = dispatch_semaphore_create(1);
        _queue = [[NSOperationQueue alloc] init];
        _filterModels = [[DDPCacheManager shareCacheManager].danmakuFilters copy];
    }
    return self;
}

- (void)reloadDataWithTime:(NSInteger)time {
    Lock();
    _filterModels = [[DDPCacheManager shareCacheManager].danmakuFilters copy];
    [_filterFlagDic removeAllObjects];
    Unlock();
    
    [self asynFilterDanmakuWithTime:time];
}

- (NSArray<JHBaseDanmaku *> *)damakusAtTime:(NSInteger)time {
    
    Lock();
    let models = self.danmakusDic[@(time)];
    Unlock();
    
    return models;
}

//处理某个时刻的弹幕
- (void)handleDanmauWithTime:(NSInteger)time {
    let danmakuFilters = self.filterModels;
    
    let timeIndex = @(time);
    let arr = self.danmakusDic[timeIndex];
    //已经分析过
    if (arr == nil || self.filterFlagDic[timeIndex]) return;
    
    [arr enumerateObjectsUsingBlock:^(JHBaseDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.filter = [DDPDanmakuManager filterWithDanmakuContent:obj.attributedString.string danmakuFilters:danmakuFilters];
    }];
    
    self.filterFlagDic[timeIndex] = @(true);
}

- (void)asynFilterDanmakuWithTime:(NSInteger)time {

    [_queue cancelAllOperations];
    
    //主线程先分析一部分弹幕
    
    Lock();
    for (NSInteger i = time; i < time + PARSE_TIME; ++i) {
        [self handleDanmauWithTime:i];
        
    }
    Unlock();
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    @weakify(op)
    [op addExecutionBlock:^{
        @strongify(op)
        if (!self || !op || op.isCancelled) return;
        
        //子线程继续分析
        let allKeys = [self.danmakusDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        if (op.isCancelled) {
            return;
        }
        
        Lock();
        for (NSInteger i = 0; i < allKeys.count; ++i) {
            @autoreleasepool {
                if (op.isCancelled) {
                    return;
                }
                
                let obj = allKeys[i];
                
                if (obj.integerValue >= time) {
                    [self handleDanmauWithTime:obj.integerValue];
                }
            }
        }
        Unlock();
    }];
    
    [_queue addOperation:op];
    
}

#pragma mark - 懒加载
- (NSMutableDictionary<NSNumber *,NSNumber *> *)filterFlagDic {
    if (_filterFlagDic == nil) {
        _filterFlagDic = [NSMutableDictionary dictionary];
    }
    return _filterFlagDic;
}

@end
