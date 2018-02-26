//
//  DDPBaseNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBaseNetManager.h"
#import <AFNetworking.h>
#import "DDPHTTPRequestSerializer.h"
#import "DDPHTTPResponseSerializer.h"
//#import "DDPHTTPNoParseResponseSerializer.h"
//#import "DDPHTTPNoParseRequestSerializer.h"
//#import "DDPHTTPXMLResponseSerializer.h"

#define ddp_HTTP_TIME_OUT 10

@interface DDPBaseNetManager ()
//<DDPHTTPSerializerDelegate>
//@property (strong, nonatomic) AFHTTPSessionManager *JSONSessionManager;
//@property (strong, nonatomic) AFHTTPSessionManager *XMLSessionManager;
@property (strong, nonatomic) AFHTTPSessionManager *HTTPSessionManager;
@property (strong, nonatomic) YYReachability *reachability;
//@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <NSNumber *>*>*URLDic;
@end

/**
 *  转换错误信息为可读
 *
 *  @param error 错误
 *
 *  @return 可读的错误
 */
static NSError *ddp_humanReadableError(NSError *error) {
    if (error == nil) return nil;
    
    NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    NSUInteger statusCode = response.statusCode;
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"%lu ", (unsigned long)statusCode];
    if (statusCode == 400) {
        [str appendString:@"客户端发送的请求有错误"];
    }
    else if (statusCode == 401) {
        [str appendString:@"客户端无权限或token验证失败"];
    }
    else if (statusCode == 404) {
        [str appendString:@"未找到API"];
    }
    else if (statusCode == 500) {
        [str appendString:@"服务器处理请求时发生错误"];
    }
    
    JHLog(@"%@", str);
    
    NSError *aError = [NSError errorWithDomain:@"网络错误" code:statusCode userInfo:@{NSLocalizedDescriptionKey : @"网络错误"}];
    return aError;
}

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

+ (instancetype)shareNetManager {
    static dispatch_once_t onceToken;
    static DDPBaseNetManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[DDPBaseNetManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
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
    return [manager GET:path parameters:ddp_requestParameters(serializerType, parameters) progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        JHLog(@"GET 请求成功：%@ \n\n%@", task.originalRequest.URL, ddp_jsonString(responseObject));
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        JHLog(@"GET 请求失败：%@ \n\n%@", task.originalRequest.URL, error);
        NSError *temErr = ddp_humanReadableError(error);
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:temErr]);
        }
    }];
}

- (NSURLSessionDataTask *)POSTWithPath:(NSString *)path
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
    
    return [manager POST:path parameters:ddp_requestParameters(serializerType, parameters) progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        JHLog(@"POST 请求成功：%@\n\n%@", path, ddp_jsonString(responseObject));
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        JHLog(@"POST 请求失败：%@ \n\n %@ \n\n%@", path, parameters, error);
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:ddp_humanReadableError(error)]);
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
    
    return [manager DELETE:path parameters:ddp_requestParameters(serializerType, parameters) success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        JHLog(@"DELETE 请求成功：%@\n\n%@", path, ddp_jsonString(responseObject));
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        JHLog(@"DELETE 请求失败：%@ \n\n %@ \n\n%@", path, parameters, error);
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:ddp_humanReadableError(error)]);
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
    
    return [manager PUT:path parameters:ddp_requestParameters(serializerType, parameters) success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        JHLog(@"PUT 请求成功：%@\n\n%@", path, ddp_jsonString(responseObject));
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        JHLog(@"PUT 请求失败：%@ \n\n %@ \n\n%@", path, parameters, error);
        
        if (completionHandler) {
            completionHandler([[DDPResponse alloc] initWithResponseObject:nil error:ddp_humanReadableError(error)]);
        }
    }];
}

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
        
        NSURLSessionDataTask *dataTask = [manager GET:obj parameters:ddp_requestParameters(serializerType, nil) progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

//#pragma mark - DDPHTTPSerializerDelegate
//- (DDPBaseNetManagerSerializerType)serializerTypeWithURL:(NSURL *)url type:(DDPHTTPSerializerType)type {
//    return [self.URLDic[url.absoluteString].firstObject integerValue];
//}
//
//- (void)serializerDidResponseWithURL:(NSURL *)url {
//    [self.URLDic[url.absoluteString] removeLastObject];
//}

//#pragma mark - 私有方法
//- (void)addTypeToCache:(DDPBaseNetManagerSerializerType)type path:(NSString *)path {
//    NSMutableArray *arr = self.URLDic[path];
//    if (arr == nil) {
//        arr = [NSMutableArray array];
//        self.URLDic[path] = arr;
//    }
//    [arr addObject:@(type)];
//}

#pragma mark - 懒加载
//- (AFHTTPSessionManager *)JSONSessionManager {
//    if (_JSONSessionManager == nil) {
//        _JSONSessionManager = [AFHTTPSessionManager manager];
//        NSDictionary *dic = ddp_defaultHTTPHeaderField();
//        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            [_JSONSessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
//        }];
//        _JSONSessionManager.requestSerializer.timeoutInterval = ddp_HTTP_TIME_OUT;
//    }
//    return _JSONSessionManager;
//}
//
//- (AFHTTPSessionManager *)XMLSessionManager {
//    if (_XMLSessionManager == nil) {
//        _XMLSessionManager = [AFHTTPSessionManager manager];
//        _XMLSessionManager.responseSerializer = [DDPHTTPXMLResponseSerializer serializer];
//        _XMLSessionManager.requestSerializer = [DDPHTTPNoParseRequestSerializer serializer];
//        [_XMLSessionManager.requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml" forHTTPHeaderField:@"accept"];
//
//        NSDictionary *dic = ddp_defaultHTTPHeaderField();
//        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            [_XMLSessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
//        }];
//        _XMLSessionManager.requestSerializer.timeoutInterval = ddp_HTTP_TIME_OUT;
//    }
//    return _XMLSessionManager;
//}

- (AFHTTPSessionManager *)HTTPSessionManager {
    if (_HTTPSessionManager == nil) {
        _HTTPSessionManager = [AFHTTPSessionManager manager];
        _HTTPSessionManager.responseSerializer = ({
            DDPHTTPResponseSerializer *serializer = [DDPHTTPResponseSerializer serializer];
//            serializer.delegate = self;
            serializer;
        });
        _HTTPSessionManager.requestSerializer = ({
            DDPHTTPRequestSerializer *serializer = [DDPHTTPRequestSerializer serializer];
//            serializer.delegate = self;
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

//- (NSMutableDictionary *)URLDic {
//    if (_URLDic == nil) {
//        _URLDic = [NSMutableDictionary dictionary];
//    }
//    return _URLDic;
//}

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
