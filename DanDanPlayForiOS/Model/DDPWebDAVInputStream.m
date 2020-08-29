//
//  DDPWebDAVInputStream.m
//  DDPlay
//
//  Created by JimHuang on 2020/5/30.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVInputStream.h"
#import "AFWebDAVManager.h"

static NSUInteger kDefaultDownloadSize = 16 * 1024 * 1024;

#ifdef DEBUG
#define TestLog(...) NSLog(__VA_ARGS__)
#else
#define TestLog(...)
#endif

@interface DDPPartTask : NSObject
@property (nonatomic, strong, readonly) NSString *rangeString;
@property (nonatomic, assign, readonly) NSRange range;
@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, assign) BOOL cached;
@property (atomic, assign) CGFloat downloadProgress;
@property (atomic, assign, getter=isRequesting) BOOL requesting;

- (instancetype)initWithRange:(NSRange)range index:(NSInteger)index;
@end

@implementation DDPPartTask

- (instancetype)initWithRange:(NSRange)range index:(NSInteger)index {
    self = [super init];
    if (self) {
        _range = range;
        _index = index;
        _rangeString = [NSString stringWithFormat:@"bytes=%@-%@", @(range.location), @(NSMaxRange(range))];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"range: %@, index: %@", _rangeString, @(_index)];
}

@end

@interface DDPWebDAVInputStream ()
@property (nonatomic, strong, readonly) AFWebDAVManager *manager;
@property (nonatomic, assign) NSUInteger readOffset;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSUInteger fileLength;
@property (nonatomic, strong) NSDictionary <NSNumber *, DDPPartTask *>*cacheRangeDic;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, strong) dispatch_queue_t writeQueue;
@end

@implementation DDPWebDAVInputStream {
    __weak id<NSStreamDelegate> _delegate;
}

@synthesize streamStatus = _streamStatus;
@synthesize streamError = _streamError;

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url fileLength:0];
}

- (instancetype)initWithURL:(NSURL *)url fileLength:(NSInteger)fileLength {
    self = [super initWithURL:url];
    if (self) {
        _url = url;
        [self setupInit];
        if (fileLength > 0) {
            [self generateTasksWithFileLength:fileLength];
        }
    }
    return self;
}

- (void)setupInit {
    _writeQueue = dispatch_queue_create("com.dandanplay.weddav.write", DISPATCH_QUEUE_SERIAL);
    _cachePath = UIApplication.sharedApplication.cachesPath;
    _cachePath = [_cachePath stringByAppendingPathComponent:self.url.lastPathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_cachePath error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:_cachePath contents:nil attributes:nil];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_cachePath];
    self.inputStream = [NSInputStream inputStreamWithFileAtPath:_cachePath];
}

- (void)open {
    _streamStatus = NSStreamStatusOpen;
    [self.inputStream open];
}

- (BOOL)hasBytesAvailable {
    if (self.fileLength > 0) {
        return self.fileLength - _readOffset > 0;
    }
    return YES;
}

- (id)propertyForKey:(NSString *)key {
    if (![key isEqualToString:NSStreamFileCurrentOffsetKey]) {
        return nil;
    }
    return @(_readOffset);
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    if (![key isEqualToString:NSStreamFileCurrentOffsetKey]) {
        return NO;
    }
    if (![property isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    NSUInteger requestedOffest = [property unsignedIntegerValue];
    self.readOffset = requestedOffest;
    return YES;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)bufferLength {
    return NO;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength {
    
    if (!self.cacheRangeDic) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self generateTasksWithCompletion:^(NSDictionary<NSNumber *,DDPPartTask *> *cacheRangeDic) {
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    NSRange dataRange = NSMakeRange(_readOffset, MIN(maxLength, MAX(self.fileLength - _readOffset, 0)));
    //    TestLog(@"读取 %@", [NSValue valueWithRange:dataRange]);
    
    if (self.fileLength > 0 && _readOffset >= self.fileLength) {
        _streamStatus = NSStreamStatusAtEnd;
        return 0;
    }
    
    
    NSInteger lower = dataRange.location / kDefaultDownloadSize;
    NSInteger upper = NSMaxRange(dataRange) / kDefaultDownloadSize;
    
    //    TestLog(@"lower %ld, upper %ld", lower, upper);
    NSMutableArray <DDPPartTask *>*shouldDownloadTasks = [NSMutableArray array];
    for (NSInteger i = lower; i <= upper; ++i) {
        NSNumber *key = @(i);
        DDPPartTask *aTask = self.cacheRangeDic[key];
        
        if (!aTask.cached && !aTask.isRequesting) {
            [shouldDownloadTasks addObject:aTask];
        }
    }
    
    if (shouldDownloadTasks.count > 0) {
        
        dispatch_group_t group = dispatch_group_create();
        CGFloat totalCount = shouldDownloadTasks.count;
        
        if ([self.delegate respondsToSelector:@selector(inputStream:downloadProgress:)]) {
            [((id<DDPWebDAVInputStreamDelegate>)self.delegate) inputStream:self downloadProgress:0];
        }
        
        [shouldDownloadTasks enumerateObjectsUsingBlock:^(DDPPartTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_enter(group);
            [self getPartOfFileWithTask:obj progressHandler:^(CGFloat progress) {
                obj.downloadProgress = progress;
                if ([self.delegate respondsToSelector:@selector(inputStream:downloadProgress:)]) {
                    
                    __block CGFloat completionProgress = 0;
                    [shouldDownloadTasks enumerateObjectsUsingBlock:^(DDPPartTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        completionProgress += obj.downloadProgress;
                    }];
                    
                    [((id<DDPWebDAVInputStreamDelegate>)self.delegate) inputStream:self downloadProgress:completionProgress / totalCount];
                }
            } completion:^(DDPPartTask *task) {
                task.downloadProgress = 1;
                dispatch_group_leave(group);
            }];
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        if ([self.delegate respondsToSelector:@selector(inputStream:downloadProgress:)]) {
            [((id<DDPWebDAVInputStreamDelegate>)self.delegate) inputStream:self downloadProgress:1];
        }
    }
    
    __unused NSInteger result = [self.inputStream read:buffer maxLength:dataRange.length];
//    TestLog(@"read result %ld", result);
    self.readOffset += dataRange.length;
    return dataRange.length;
}

- (void)setReadOffset:(NSUInteger)readOffset {
    _readOffset = readOffset;
    [self.inputStream setProperty:@(_readOffset) forKey:NSStreamFileCurrentOffsetKey];
}

//- (void)dealloc {
//    [self close];
//}

- (void)close {
    _streamStatus = NSStreamStatusClosed;
    [self.inputStream close];
    [self.fileHandle closeFile];
    if ([_delegate respondsToSelector:@selector(stream:handleEvent:)]) {
        [_delegate stream:self handleEvent:NSStreamEventEndEncountered];
    }
}

- (void)setDelegate:(id<NSStreamDelegate>)delegate {
    _delegate = delegate;
}

- (id<NSStreamDelegate>)delegate {
    return _delegate;
}

#pragma mark - Private Method
- (void)generateTasksWithFileLength:(NSInteger)fileLength {
    
    if (fileLength == 0) {
        self.cacheRangeDic = @{};
        return;
    }
    
    self.fileLength = fileLength;
    
    NSInteger taskCount = ceil(fileLength * 1.0 / kDefaultDownloadSize);
    NSMutableDictionary<NSNumber *,DDPPartTask *> *taskDic = [NSMutableDictionary dictionaryWithCapacity:taskCount];
    
    if (taskCount == 0) {
        NSRange tmpRange = NSMakeRange(0, fileLength - 1);
        taskDic[@(0)] = [[DDPPartTask alloc] initWithRange:tmpRange index:0];
    } else {
        for (NSInteger i = 0; i < taskCount; ++i) {
            NSRange tmpRange = NSMakeRange(i * kDefaultDownloadSize, kDefaultDownloadSize - 1);
            //最后一个range.length不一定是kDefaultDownloadSize的整数倍，需要根据文件实际长度处理
            if (i == taskCount - 1) {
                tmpRange.length = fileLength - tmpRange.location - 1;
            }
            
            taskDic[@(i)] = [[DDPPartTask alloc] initWithRange:tmpRange index:i];
        }
    }
    
    self.cacheRangeDic = taskDic;
}

- (void)generateTasksWithCompletion:(void(^)(NSDictionary <NSNumber *, DDPPartTask *>*cacheRangeDic))completion {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
    [req setValue:[NSString stringWithFormat:@"bytes=0-%@", @(1024)] forHTTPHeaderField:@"Range"];
    
    [[self.manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, NSData * _Nullable responseObject, NSError * _Nullable error) {
        
        if (responseObject.length > 0) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *contentRange = httpResponse.allHeaderFields[@"Content-Range"];
            NSInteger fileLength = [contentRange componentsSeparatedByString:@"/"].lastObject.integerValue;
            
            [self generateTasksWithFileLength:fileLength];
        } else {
            self.cacheRangeDic = @{};
        }
        
        if (completion) {
            completion(self.cacheRangeDic);
        }
        
    }] resume];
}

- (void)getPartOfFileWithTask:(DDPPartTask *)task
              progressHandler:(void(^)(CGFloat progress))progressHandler
                   completion:(void(^)(DDPPartTask *task))completion {
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
    
    if (task.cached) {
        
        if (progressHandler) {
            progressHandler(1);
        }
        
        if (completion) {
            completion(task);
        }
        return;
    }
    
    //当前正在下载
    if (task.isRequesting) {
        return;
    }
    
    task.requesting = YES;
    
    [req setValue:task.rangeString forHTTPHeaderField:@"Range"];
    
    TestLog(@"=== 开始下载 %@", task);
    @weakify(self)
    [[self.manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:^(NSProgress *progress) {
        if (progressHandler) {
            progressHandler(progress.fractionCompleted);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSData * _Nullable responseObject, NSError * _Nullable error) {
        
        @strongify(self)
        if (!self) {
            if (completion) {
                completion(task);
            }
            return;
        }
        
        task.requesting = NO;
        
        if (responseObject.length > 0) {
            task.cached = YES;
            
            [self.fileHandle seekToFileOffset:task.range.location];
            [self.fileHandle writeData:responseObject];
            [self.fileHandle synchronizeFile];
        }
        
        if (completion) {
            completion(task);
        }
        
        TestLog(@"=== 下载完成 %@", task);
        
    }] resume];
    
    
}

#pragma mark - Property Method (Private)

- (AFWebDAVManager *)manager {
    static AFWebDAVManager *_manager = nil;
    if (!_manager) {
        _manager = [[AFWebDAVManager alloc] init];
        _manager.completionQueue = self.writeQueue;
        [_manager setAuthenticationChallengeHandler:^id _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, void (^ _Nonnull completionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable)) {
            
            if (challenge.previousFailureCount > 0) {
                return [NSError errorWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"认证失败"}];
            }
            
            NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;
            if ([authenticationMethod isEqual:NSURLAuthenticationMethodHTTPDigest] ||
                [authenticationMethod isEqual:NSURLProtectionSpaceHTTPS]) {
                let info = DDPToolsManager.shareToolsManager.webDAVLoginInfo;
                return [NSURLCredential credentialWithUser:info.userName
                                                  password:info.userPassword
                                               persistence:NSURLCredentialPersistenceForSession];
            }
            
            return @(NSURLSessionAuthChallengePerformDefaultHandling);
            
        }];
    }
    return _manager;
}

@end
