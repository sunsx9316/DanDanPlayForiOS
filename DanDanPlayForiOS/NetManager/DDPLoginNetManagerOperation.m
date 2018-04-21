//
//  DDPLoginNetManagerOperation.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLoginNetManagerOperation.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "DDPPofileResponse.h"

@implementation DDPLoginNetManagerOperation

+ (NSURLSessionDataTask *)loginWithSource:(DDPUserType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(DDPUser *responseObject, NSError *error))completionHandler {

    if (userId.length == 0 || token.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/applogin?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = @{@"Source" : ddp_userTypeToString(source), @"UserId" : userId, @"AccessToken" : token, @"Timestamp" : @((UInt64)([[NSDate date] timeIntervalSince1970]))};
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                  parameters:ddplay_encryption(dic)
                                           completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else {
            DDPUser *user = [DDPUser yy_modelWithJSON:responseObj.responseObject];
            user.account = userId;
            user.password = token;
            user.loginUserType = source;
            //登录失败
            if (user.needLogin == YES) {
                if (completionHandler) {
                    completionHandler(user, DDPErrorWithCode(DDPErrorCodeLoginFail));
                }
            }
            else {
                [DDPCacheManager shareCacheManager].user = user;
                if (completionHandler) {
                    completionHandler(user, responseObj.error);
                }
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterWithRequest:(DDPRegisterRequest *)request
                                 completionHandler:(void(^)(DDPRegisterResponse *responseObject, NSError *error))completionHandler {
    if (request.name.length == 0 || request.password.length == 0 || request.email.length == 0 || request.account.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [request yy_modelToJSONObject];
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                  parameters:ddplay_encryption(dic)
                                           completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else {
            DDPRegisterResponse *response = [DDPRegisterResponse yy_modelWithJSON:responseObj.responseObject];
            if (response.success == NO) {
                
                NSError *err = DDPErrorWithCode(DDPErrorCodeRegisterFail);
                if (completionHandler) {
                    completionHandler(response, err);
                }
            }
            else {
                if (completionHandler) {
                    completionHandler(response, nil);
                }
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterRelateToThirdPartyWithRequest:(DDPRegisterRequest *)request
                                                   completionHandler:(void(^)(DDPRegisterResponse *responseObject, NSError *error))completionHandler {
    
    if (request.name.length == 0 || request.password.length == 0 || request.email.length == 0 || request.account.length == 0 || request.userId.length == 0 || request.token == 0){
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/relate?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserName", @"Password", @"Email", @"ScreenName", @"UserId", @"Token"]];
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                  parameters:ddplay_encryption(dic)
                                           completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            if (completionHandler) {
                completionHandler(nil, responseObj.error);
            }
        }
        else {
            DDPRegisterResponse *response = [DDPRegisterResponse yy_modelWithJSON:responseObj.responseObject];
            if (response.success == NO) {
                NSError *err = DDPErrorWithCode(DDPErrorCodeRegisterFail);
                if (completionHandler) {
                    completionHandler(response, err);
                }
            }
            else {
                if (completionHandler) {
                    completionHandler(response, nil);
                }
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterRelateOnlyWithRequest:(DDPRegisterRequest *)request
                                           completionHandler:(void(^)(DDPRegisterResponse *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (request.userId.length == 0 || request.token.length == 0 || request.account.length == 0 || request.password.length == 0){
        completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/relateonly?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserId", @"Token", @"UserName", @"Password"]];
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON
                                                  parameters:ddplay_encryption(dic)
                                           completionHandler:^(DDPResponse *responseObj) {
        if (responseObj.error) {
            completionHandler(nil, responseObj.error);
        }
        else {
            DDPRegisterResponse *response = [DDPRegisterResponse yy_modelWithJSON:responseObj.responseObject];
            if (response.success == NO) {
                NSError *err = DDPErrorWithCode(DDPErrorCodeBindingFail);
                completionHandler(response, err);
            }
            else {
                completionHandler(response, nil);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginEditUserNameWithUserId:(NSUInteger)userId
                                                token:(NSString *)token
                                             userName:(NSString *)userName
                                    completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId == 0 || token.length == 0 || userName.length == 0){
        completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/user/profile", [DDPMethod apiPath]];
    NSDictionary *parameters = @{@"UserId" : @(userId), @"Token" : token, @"ScreenName" : userName};
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                  parameters:parameters
                                           completionHandler:^(DDPResponse *responseObj) {
        DDPPofileResponse *response = [DDPPofileResponse yy_modelWithJSON:responseObj.responseObject];
        if (responseObj.error) {
            completionHandler(responseObj.error);
        }
        else if (response.updateScreenNameSuccess == NO) {
            NSError *err = DDPErrorWithCode(DDPErrorCodeUpdateUserNameFail);
            completionHandler(err);
        }
        else {
            completionHandler(nil);
        }
    }];
}

+ (NSURLSessionDataTask *)loginEditPasswordWithUserId:(NSUInteger)userId
                                                token:(NSString *)token
                                          oldPassword:(NSString *)oldPassword
                                         aNewPassword:(NSString *)aNewPassword
                                    completionHandler:(void(^)(NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId == 0 || token.length == 0 || oldPassword.length == 0 || aNewPassword.length == 0){
        completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/user/profile", [DDPMethod apiPath]];
    NSDictionary *parameters = @{@"UserId" : @(userId), @"Token" : token, @"OldPassword" : oldPassword, @"NewPassword" : aNewPassword};
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path
                                              serializerType:DDPBaseNetManagerSerializerTypeJSON
                                                  parameters:parameters
                                           completionHandler:^(DDPResponse *responseObj) {
        DDPPofileResponse *response = [DDPPofileResponse yy_modelWithJSON:responseObj.responseObject];
        if (responseObj.error) {
            completionHandler(responseObj.error);
        }
        else if (response.updatePasswordSuccess == NO) {
            NSError *err = DDPErrorWithCode(DDPErrorCodeUpdateUserPasswordFail);
            completionHandler(err);
        }
        else {
            completionHandler(nil);
        }
    }];
}

@end
