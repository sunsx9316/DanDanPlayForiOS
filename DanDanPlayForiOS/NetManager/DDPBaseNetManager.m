//
//  DDPBaseNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "DDPHTTPRequestSerializer.h"
#import "DDPHTTPResponseSerializer.h"

#define ddp_HTTP_TIME_OUT 10

@interface DDPBaseNetManager ()
@property (strong, nonatomic) AFHTTPSessionManager *HTTPSessionManager;
@property (strong, nonatomic) AFHTTPSessionManager *defaultHTTPSessionManager;
@property (strong, nonatomic) YYReachability *reachability;
@end

static NSString *ddp_jsonString(id obj) {
    if ([obj isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:nil];
    }
    else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:obj]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return json;
        }
    }
    return nil;
};

CG_INLINE NSDictionary *ddp_defaultHTTPHeaderField() {
    return @{@"X-Client-Name" : @"iOS",
             @"X-Client-Version" : [UIApplication sharedApplication].appVersion
             };
};

static DDPRequestParameters *ddp_requestParameters(DDPBaseNetManagerSerializerType type, id parameters) {
    return [[DDPRequestParameters alloc] initWithType:type parameters:parameters];
}


@implementation DDPBaseNetManager
{
    NSHashTable *_observers;
}


- (instancetype)init {
    if (self = [super init]) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        //开启网络的指示符
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return self;
}



#pragma mark -

- (NSURLSessionDataTask *)GETWithPath:(NSString*)path
                       serializerType:(DDPBaseNetManagerSerializerType)serializerType
                           parameters:(id)parameters
                    completionHandler:(DDPResponseCompletionAction)completionHandler {
    if (path.length == 0) {
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:DDPErrorWithCode(DDPErrorCodeParameterNoCompletion)]);
        }
        return nil;
    }
    
    AFHTTPSessionManager *manager = self.HTTPSessionManager;
    return [manager GET:path parameters:ddp_requestParameters(serializerType, parameters) headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        LOG_DEBUG(DDPLogModuleNetwork, @"GET 请求成功：%@ \n\n%@", task.originalRequest.URL, ddp_jsonString(responseObject));
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LOG_DEBUG(DDPLogModuleNetwork, @"GET 请求失败：%@ \n\n%@", task.originalRequest.URL, error);
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:error]);
        }
    }];
}

- (NSURLSessionDataTask *)POSTWithPath:(NSString *)path serializerType:(DDPBaseNetManagerSerializerType)serializerType parameters:(id)parameters completionHandler:(DDPResponseCompletionAction)completionHandler {
    if (path.length == 0) {
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:DDPErrorWithCode(DDPErrorCodeParameterNoCompletion)]);
        }
        return nil;
    }
    
    AFHTTPSessionManager *manager = self.HTTPSessionManager;
    
    return [manager POST:path parameters:ddp_requestParameters(serializerType, parameters) headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LOG_DEBUG(DDPLogModuleNetwork, @"POST 请求成功：%@\n\n%@\n\n%@", path, ddp_jsonString(parameters) , ddp_jsonString(responseObject));
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LOG_DEBUG(DDPLogModuleNetwork, @"POST 请求失败：%@ \n\n %@ \n\n%@", path, ddp_jsonString(parameters), error);
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:error]);
        }
    }];
}

- (NSURLSessionDataTask *)DELETEWithPath:(NSString *)path
                          serializerType:(DDPBaseNetManagerSerializerType)serializerType
                              parameters:(id)parameters
                       completionHandler:(DDPResponseCompletionAction)completionHandler {
    if (path.length == 0) {
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:DDPErrorWithCode(DDPErrorCodeParameterNoCompletion)]);
        }
        return nil;
    }
    
    AFHTTPSessionManager *manager = self.HTTPSessionManager;
    
    return [manager DELETE:path parameters:ddp_requestParameters(serializerType, parameters) headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LOG_DEBUG(DDPLogModuleNetwork, @"DELETE 请求成功：%@\n\n%@", path, ddp_jsonString(responseObject));
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LOG_DEBUG(DDPLogModuleNetwork, @"DELETE 请求失败：%@ \n\n %@ \n\n%@", path, parameters, error);
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:error]);
        }
    }];
}

- (NSURLSessionDataTask *)PUTWithPath:(NSString *)path
                           serializerType:(DDPBaseNetManagerSerializerType)serializerType parameters:(id)parameters
                    completionHandler:(DDPResponseCompletionAction)completionHandler {
    if (path.length == 0) {
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:DDPErrorWithCode(DDPErrorCodeParameterNoCompletion)]);
        }
        return nil;
    }
    
    AFHTTPSessionManager *manager = self.HTTPSessionManager;
    
    return [manager PUT:path parameters:ddp_requestParameters(serializerType, parameters) headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LOG_DEBUG(DDPLogModuleNetwork, @"PUT 请求成功：%@\n\n%@", path, ddp_jsonString(responseObject));
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LOG_DEBUG(DDPLogModuleNetwork, @"PUT 请求失败：%@ \n\n %@ \n\n%@", path, parameters, error);
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:error]);
        }
    }];
}

#if DDPAPPTYPEISMAC
- (NSURLSessionDownloadTask *)downloadTaskWithPath:(NSString *)path
                                          progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                       destination:(NSURL *(^)(NSURL *targetPath, NSURLResponse *response))destination
                                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    
    AFHTTPSessionManager *manager = self.defaultHTTPSessionManager;
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] progress:downloadProgressBlock destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        LOG_DEBUG(DDPLogModuleNetwork, @"下载%@：%@", error ? @"失败" : @"成功", path);
        completionHandler(response, filePath, error);
    }];
    
    [task resume];
    
    return task;
}
#endif

- (void)batchGETWithPaths:(NSArray <NSString *>*)paths
           serializerType:(DDPBaseNetManagerSerializerType)serializerType
        editResponseBlock:(DDPBatchEditResponseObjAction)editResponseBlock
            progressBlock:(DDPProgressAction)progressBlock
        completionHandler:(DDPBatchCompletionAction)completionHandler {
    
    
    if (paths.count == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return;
    }
    
    AFHTTPSessionManager *manager = self.HTTPSessionManager;
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray <DDPBatchResponse *>*responseObjects = [NSMutableArray array];
    
    __block NSError *err;
    __block float currentIndex = 0.0f;
    NSInteger taskCount = paths.count;
    
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_group_enter(group);
        
        NSURLSessionDataTask *dataTask = [manager GET:obj parameters:ddp_requestParameters(serializerType, nil) headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            currentIndex++;
            
            if (editResponseBlock) {
                responseObject = editResponseBlock(responseObject);
            }
            
            if (progressBlock) {
                progressBlock(currentIndex / taskCount);
            }
            
            DDPBatchResponse *res = [[DDPBatchResponse alloc] initWithResponseObject:responseObject error:nil];
            res.task = task;
            [responseObjects addObject:res];
            
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            err = error;
            
            currentIndex++;
            
            if (progressBlock) {
                progressBlock(currentIndex / taskCount);
            }
            
            DDPBatchResponse *res = [[DDPBatchResponse alloc] initWithResponseObject:nil error:error];
            res.task = task;
            [responseObjects addObject:res];
            
            dispatch_group_leave(group);
        }];
        
        [dataTask resume];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionHandler) {
            completionHandler(responseObjects, err);
        }
    });
}

- (void)addObserver:(id<DDPBaseNetManagerObserver>)observer {
    if (observer) {
        [_observers addObject:observer];
    }
}

- (void)removeObserver:(id<DDPBaseNetManagerObserver>)observer {
    if (observer) {
        [_observers removeObject:observer];
    }
}

#pragma mark - 懒加载

- (AFHTTPSessionManager *)HTTPSessionManager {
    if (_HTTPSessionManager == nil) {
        _HTTPSessionManager = [AFHTTPSessionManager manager];
        _HTTPSessionManager.responseSerializer = ({
            DDPHTTPResponseSerializer *serializer = [DDPHTTPResponseSerializer serializer];
            serializer;
        });
        
        _HTTPSessionManager.requestSerializer = ({
            DDPHTTPRequestSerializer *serializer = [DDPHTTPRequestSerializer serializer];
            [serializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            serializer;
        });
        
        NSDictionary *dic = ddp_defaultHTTPHeaderField();
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_HTTPSessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
        _HTTPSessionManager.requestSerializer.timeoutInterval = ddp_HTTP_TIME_OUT;
    }
    return _HTTPSessionManager;
}

- (AFHTTPSessionManager *)defaultHTTPSessionManager {
    if (_defaultHTTPSessionManager == nil) {
        _defaultHTTPSessionManager = [AFHTTPSessionManager manager];
        _defaultHTTPSessionManager.requestSerializer.timeoutInterval = ddp_HTTP_TIME_OUT;
        [_defaultHTTPSessionManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        NSDictionary *dic = ddp_defaultHTTPHeaderField();
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_defaultHTTPSessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    return _defaultHTTPSessionManager;
}

- (YYReachability *)reachability {
    if (_reachability == nil) {
        _reachability = [[YYReachability alloc] init];
        @weakify(self)
        _reachability.notifyBlock = ^(YYReachability * _Nonnull reachability) {
            @strongify(self)
            if (!self) return;
            
            for (id<DDPBaseNetManagerObserver>obj in [self->_observers copy]) {
                if ([obj respondsToSelector:@selector(netStatusChange:)]) {
                    [obj netStatusChange:reachability];
                }
            }
        };
    }
    return _reachability;
}

@end
