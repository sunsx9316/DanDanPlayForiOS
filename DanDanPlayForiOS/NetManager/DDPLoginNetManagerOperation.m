//
//  DDPLoginNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLoginNetManagerOperation.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "DDPSharedNetManager.h"

@implementation DDPLoginNetManagerOperation

+ (NSURLSessionDataTask *)loginWithSource:(DDPUserLoginType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(DDPUser *responseObject, NSError *error))completionHandler {

    if (userId.length == 0 || token.length == 0 || source.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSDictionary *dic = nil;
    NSString *path;
    
    if ([source isEqualToString:DDPUserLoginTypeDefault]) {
        path = [NSString stringWithFormat:@"%@/login", [DDPMethod apiNewPath]];
        dic = [self addAuthWithParameters:@{@"password" : token,
                                            @"userName" : userId}];
    }
    //第三方登录
    else {
        path = [NSString stringWithFormat:@"%@/applogin", [DDPMethod apiNewPath]];
        dic = [self addAuthWithParameters:@{@"source" : source,
                                            @"userId" : userId,
                                            @"accessToken" : token}];
    }
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:dic completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else {
            DDPUser *user = [DDPUser yy_modelWithJSON:responseObj.responseObject];
            user.password = token;
            user.thirdPartyUserId = userId;
            user.userType = source;
            
            if (user.registerRequired == false) {
                [user updateLoginStatus:true];
                [DDPCacheManager shareCacheManager].currentUser = user;
            }
            
            if (completionHandler) {
                completionHandler(user, nil);
            }
        }
    }];
    
}

+ (NSURLSessionDataTask *)renewWithCompletionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPUser))completionHandler {
    let path = [NSString stringWithFormat:@"%@/login/renew", [DDPMethod apiNewPath]];
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:nil completionHandler:^(__kindof DDPResponse *responseObj) {
        id res = responseObj.responseObject;
        if (res) {
            let user = DDPCacheManager.shareCacheManager.currentUser;
            [user yy_modelSetWithJSON:res];
            [user updateLoginStatus:YES];
            completionHandler(user, nil);
        } else {
            var error = responseObj.error;
            if (error.code == 401) {
                let dic = [NSMutableDictionary dictionary];
                dic[NSLocalizedDescriptionKey] = @"token失效，请重新登录！";
                error = [NSError errorWithDomain:error.domain code:error.code userInfo:dic];
            }
            
            completionHandler(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)registerWithRequest:(DDPRegisterRequest *)request
                            completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPUser))completionHandler {
    if (request.name.length == 0 ||
        request.password.length == 0 ||
        request.email.length == 0 ||
        request.account.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    
    NSString *path = [NSString stringWithFormat:@"%@/register", [DDPMethod apiNewPath]];
    
    let dic = [self addAuthWithParameters:@{@"userName" : request.account,
                                            @"password" : request.password,
                                            @"email" : request.email,
                                            @"screenName" : request.name}];
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:dic completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            if (responseObj.success == false) {
                completionHandler(nil, responseObj.error);
            }
            else {
                DDPUser *user = [DDPUser yy_modelWithJSON:responseObj.responseObject];
                user.password = request.password;
                [user updateLoginStatus:true];
                [DDPCacheManager shareCacheManager].currentUser = user;
                
                completionHandler(user, responseObj.error);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)registerRelateToThirdPartyWithRequest:(DDPRegisterRequest *)request
                                              completionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPRegisterResult))completionHandler {
    
    if (request.name.length == 0 ||
        request.password.length == 0 ||
        request.email.length == 0 ||
        request.account.length == 0 ||
        request.userId.length == 0 ||
        request.token == 0){
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/relate?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserName", @"Password", @"Email", @"ScreenName", @"UserId", @"Token"]];
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(dic) completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            if (responseObj.error) {
//                responseObj.error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"注册失败"}];
                completionHandler(nil, responseObj.error);
            }
            else {
                DDPRegisterResult *result = [DDPRegisterResult yy_modelWithJSON:responseObj.responseObject];
                completionHandler(result, responseObj.error);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)relateOnlyWithRequest:(DDPRegisterRequest *)request
                              completionHandler:(DDPErrorCompletionAction)completionHandler {
    
    if (request.userId.length == 0 || request.token.length == 0 || request.account.length == 0 || request.password.length == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/relateonly?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserId", @"Token", @"UserName", @"Password"]];
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(dic) completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            if (responseObj.error) {
//                responseObj.error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"绑定失败"}];
                completionHandler(responseObj.error);
            }
            else {
                completionHandler(nil);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)editUserNameWithUserName:(NSString *)userName
                                      completionHandler:(DDPErrorCompletionAction)completionHandler {
    
    if (userName.length == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/user/profile", [DDPMethod apiNewPath]];
    NSDictionary *parameters = @{@"screenName" : userName};
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:parameters completionHandler:^(__kindof DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)editPasswordWithOldPassword:(NSString *)oldPassword
                                              aNewPassword:(NSString *)aNewPassword
                                         completionHandler:(DDPErrorCompletionAction)completionHandler {
    
    if (oldPassword.length == 0 || aNewPassword.length == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/user/password", [DDPMethod apiNewPath]];
    NSDictionary *parameters = @{@"oldPassword" : oldPassword, @"newPassword" : aNewPassword};
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:parameters completionHandler:^(DDPResponse *responseObj) {
        //弹弹的账号 更新密码
        if (responseObj.error == nil) {
            let user = [DDPCacheManager shareCacheManager].currentUser;
            if ([user.userType isEqualToString:DDPUserLoginTypeDefault]) {
                user.password = aNewPassword;
                [DDPCacheManager shareCacheManager].currentUser = user;
            }
        }
        
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)resetPasswordWithAccount:(NSString *)account
                                            email:(NSString *)email
                                completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (account.length == 0 || email.length == 0){
        completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/resetpassword", [DDPMethod apiNewPath]];
    let parameters = [self addAuthWithParameters:@{@"userName" : account, @"email" : email}];
    
    return [[DDPSharedNetManager sharedNetManager] POSTWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:parameters completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
        
    }];
}


#pragma mark - 私有方法
+ (NSDictionary *)addAuthWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *dic = [parameters mutableCopy];
    dic[@"appId"] = ddp_apiV2AppId;
    dic[@"unixTimestamp"] = @((NSInteger)[[NSDate date] timeIntervalSince1970]);
    
    NSArray <NSString *>*allKeys = [dic allKeysSorted];
    NSMutableString *str = [[NSMutableString alloc] init];
    [allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@", dic[obj]];
    }];
    [str appendString:ddp_apiV2AppSecret];
    
    dic[@"hash"] = [str md5String];
    return dic;
}

@end
