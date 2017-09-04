//
//  BaseNetManager.m
//  DanWanPlayer
//
//  Created by JimHuang on 15/12/24.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import <AFNetworking.h>
#import "AFHTTPDataResponseSerializer.h"

/**
 *  转换错误信息为可读
 *
 *  @param error 错误
 *
 *  @return 可读的错误
 */
CG_INLINE NSError *jh_humanReadableError(NSError *error) {
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
    
    NSLog(@"%@", str);
    
    NSError *aError = [NSError errorWithDomain:@"网络错误" code:statusCode userInfo:nil];
    return aError;
}


@implementation BaseNetManager
+ (AFHTTPSessionManager *)sharedHTTPSessionManager {
    static AFHTTPSessionManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"X-Client-Name"];
        [manager.requestSerializer setValue:[UIApplication sharedApplication].appVersion forHTTPHeaderField:@"X-Client-Version"];
        manager.requestSerializer.timeoutInterval = 10;
    });
    return manager;
}

+ (AFHTTPSessionManager *)sharedHTTPSessionDataManager {
    static AFHTTPSessionManager* dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [AFHTTPSessionManager manager];
        dataManager.responseSerializer = [AFHTTPDataResponseSerializer serializer];
        [dataManager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"X-Client-Name"];
        [dataManager.requestSerializer setValue:[UIApplication sharedApplication].appVersion forHTTPHeaderField:@"X-Client-Version"];
        dataManager.requestSerializer.timeoutInterval = 10;
    });
    return dataManager;
}

+ (NSURLSessionDataTask *)GETWithPath:(NSString*)path
                           parameters:(NSDictionary*)parameters
                    completionHandler:(void(^)(JHResponse *model))completionHandler {
    
    if (completionHandler == nil) return nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    return [[self sharedHTTPSessionManager] GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        
        NSLog(@"GET 请求成功：%@ \n\n%@", task.originalRequest.URL, [responseObject jsonStringEncoded]);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        completionHandler([[JHResponse alloc] initWithResponseObject:responseObject error:nil]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"GET 请求失败：%@ \n\n%@", task.originalRequest.URL, error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSError *temErr = jh_humanReadableError(error);
        
        completionHandler([[JHResponse alloc] initWithResponseObject:nil error:temErr]);
    }];
}

+ (NSURLSessionDataTask *)GETDataWithPath:(NSString*)path
                               parameters:(NSDictionary*)parameters
                        completionHandler:(void(^)(JHResponse *model))completionHandler {
    return [self GETDataWithPath:path parameters:parameters headerField:nil completionHandler:completionHandler];
}

+ (NSURLSessionDataTask *)GETDataWithPath:(NSString*)path
                               parameters:(NSDictionary*)parameters
                              headerField:(NSDictionary *)headerField
                        completionHandler:(void(^)(JHResponse *model))completionHandler {
    
    if (completionHandler == nil) return nil;
    
    [headerField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[self sharedHTTPSessionDataManager].requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    return [[self sharedHTTPSessionDataManager] GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"GETDATA 请求成功：%@ \n\n%@", task.originalRequest.URL, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [headerField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[self sharedHTTPSessionDataManager].requestSerializer setValue:nil forHTTPHeaderField:key];
        }];
        
        if (completionHandler) {
            completionHandler([[JHResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"GETDATA 请求失败：%@ \n\n%@", task.originalRequest.URL, error);
        [headerField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[self sharedHTTPSessionDataManager].requestSerializer setValue:nil forHTTPHeaderField:key];
        }];
        
        NSError *temErr = jh_humanReadableError(error);
        
        if (completionHandler) {
            completionHandler([[JHResponse alloc] initWithResponseObject:nil error:temErr]);
        }
    }];
}

+ (NSURLSessionDataTask *)PUTWithPath:(NSString *)path
                             HTTPBody:(NSData *)HTTPBody
                    completionHandler:(void(^)(JHResponse *model))completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = HTTPBody;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [[self sharedHTTPSessionManager] dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"PUT 请求失败：%@ \n\n %@", path, error);
        }
        else {
            NSLog(@"PUT 请求成功：%@", path);
        }
        
        NSError *temErr = jh_humanReadableError(error);
        completionHandler([[JHResponse alloc] initWithResponseObject:response error:temErr]);
    }];
    [task resume];
    return task;
}

+ (NSURLSessionDataTask *)DELETEWithPath:(NSString *)path
                              parameters:(id)parameters
                       completionHandler:(void(^)(JHResponse *model))completionHandler {
    return [[self sharedHTTPSessionManager] DELETE:path parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completionHandler) {
            completionHandler([[JHResponse alloc] initWithResponseObject:responseObject error:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completionHandler) {
            completionHandler([[JHResponse alloc] initWithResponseObject:nil error:jh_humanReadableError(error)]);
        }
    }];
}

+ (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    
    NSURLSessionDownloadTask *task = [[self sharedHTTPSessionManager] downloadTaskWithResumeData:resumeData progress:downloadProgressBlock destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载%@：%@", error ? @"失败" : @"成功", response.URL);
        completionHandler(response, filePath, error);
    }];
    [task resume];
    
    return task;
}

+ (NSURLSessionDownloadTask *)downloadTaskWithPath:(NSString *)path
                                          progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    
    
    NSURLSessionDownloadTask *task = [[self sharedHTTPSessionManager] downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] progress:downloadProgressBlock destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载%@：%@", error ? @"失败" : @"成功", path);
        completionHandler(response, filePath, error);
    }];
    
    [task resume];
    
    return task;
}

+ (void)batchGETWithPaths:(NSArray <NSString *>*)paths
            progressBlock:(batchProgressAction)progressBlock
        completionHandler:(batchCompletionAction)completionHandler {
    [self batchRequestWithManager:[self sharedHTTPSessionManager] paths:paths progressBlock:progressBlock completionBlock:completionHandler];
}

+ (void)batchGETDataWithPaths:(NSArray <NSString *>*)paths
                progressBlock:(batchProgressAction)progressBlock
            completionHandler:(batchCompletionAction)completionHandler {
    [self batchRequestWithManager:[self sharedHTTPSessionDataManager] paths:paths progressBlock:progressBlock completionBlock:completionHandler];
}

#pragma mark - 私有方法
+ (void)batchRequestWithManager:(AFHTTPSessionManager *)manager
                          paths:(NSArray <NSString *>*)paths
                progressBlock:(batchProgressAction)progressBlock
              completionBlock:(batchCompletionAction)completionBlock {
    
    if (paths.count == 0) {
        if (completionBlock) {
            completionBlock(nil, nil, @[parameterNoCompletionError()]);
        }
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *responseObjectArr = [NSMutableArray array];
    NSMutableArray *taskArr = [NSMutableArray array];
    NSMutableArray *errorArr = [NSMutableArray array];
    
    for (NSInteger i = 0; i < paths.count ; ++i) {
        [responseObjectArr addObject:[NSNull null]];
        [taskArr addObject:[NSNull null]];
        
        NSString *path = paths[i];
        dispatch_group_enter(group);
        
        NSURLSessionDataTask *dataTask = [manager GET:path parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            if (progressBlock) {
                progressBlock(i, paths.count, &responseObject, nil);
            }
            
            @synchronized (responseObjectArr) {
                if (responseObject) {
                    responseObjectArr[i] = responseObject;
                }
            }
            @synchronized (taskArr) {
                if (task) {
                    taskArr[i] = task;
                }
            }
            dispatch_group_leave(group);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            if (progressBlock) {
                progressBlock(i, paths.count, nil, error);
            }
            
            @synchronized (taskArr) {
                if (operation) {
                    taskArr[i] = operation;
                }
                
                if (error) {
                    [errorArr addObject:error];
                }
            }
            
            dispatch_group_leave(group);
        }];
        [dataTask resume];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock(responseObjectArr, taskArr, errorArr);
        }
    });
}

+ (void)startMonitoring {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)stopMonitoring {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (void)reachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:block];
}

@end
