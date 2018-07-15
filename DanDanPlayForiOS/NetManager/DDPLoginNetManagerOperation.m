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
#import "DDPBindingResponse.h"
#import "DDPRegisterResponse.h"

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
                                 completionHandler:(void(^)(DDPRegisterResult *responseObject, NSError *error))completionHandler {
    if (request.name.length == 0 || request.password.length == 0 || request.email.length == 0 || request.account.length == 0) {
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [request yy_modelToJSONObject];
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(dic) responseClass:[DDPRegisterResponse class] completionHandler:^(DDPRegisterResponse *responseObj) {
        if (completionHandler) {
            DDPRegisterResult *result = [DDPRegisterResult yy_modelWithJSON:responseObj.responseObject];
            completionHandler(result, responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterRelateToThirdPartyWithRequest:(DDPRegisterRequest *)request
                                                   completionHandler:(void (^)(DDPRegisterResult *, NSError *))completionHandler {
    
    if (request.name.length == 0 || request.password.length == 0 || request.email.length == 0 || request.account.length == 0 || request.userId.length == 0 || request.token == 0){
        if (completionHandler) {
            completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/relate?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserName", @"Password", @"Email", @"ScreenName", @"UserId", @"Token"]];
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(dic) responseClass:[DDPRegisterResponse class] completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            DDPRegisterResult *result = [DDPRegisterResult yy_modelWithJSON:responseObj.responseObject];
            completionHandler(result, responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterRelateOnlyWithRequest:(DDPRegisterRequest *)request
                                           completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (completionHandler == nil) return nil;
    
    if (request.userId.length == 0 || request.token.length == 0 || request.account.length == 0 || request.password.length == 0){
        completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/register/relateonly?clientId=%@", [DDPMethod apiPath], CLIENT_ID];
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserId", @"Token", @"UserName", @"Password"]];
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(dic) responseClass:[DDPBindingResponse class] completionHandler:^(DDPBindingResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)loginEditUserNameWithUserId:(NSUInteger)userId
                                                token:(NSString *)token
                                             userName:(NSString *)userName
                                    completionHandler:(DDPErrorCompletionAction)completionHandler {
    
    if (userId == 0 || token.length == 0 || userName.length == 0){
        if (completionHandler) {
            completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        }
        return nil;
    }
    
    NSString *path = [DDPMethod apiPath];
    path = [NSString stringWithFormat:@"%@?clientId=%@", [path ddp_appendingPathComponent:@"/user/profile"], CLIENT_ID];
    NSDictionary *parameters = @{@"UserId" : @(userId), @"Token" : token, @"ScreenName" : userName};
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(parameters) responseClass:[DDPPofileResponse class] completionHandler:^(DDPPofileResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
    }];
}

+ (NSURLSessionDataTask *)loginEditPasswordWithUserId:(NSUInteger)userId
                                                token:(NSString *)token
                                          oldPassword:(NSString *)oldPassword
                                         aNewPassword:(NSString *)aNewPassword
                                    completionHandler:(DDPErrorCompletionAction)completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId == 0 || token.length == 0 || oldPassword.length == 0 || aNewPassword.length == 0){
        completionHandler(DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = [DDPMethod apiPath];
    path = [NSString stringWithFormat:@"%@?clientId=%@", [path ddp_appendingPathComponent:@"/user/profile"], CLIENT_ID];
    
    NSDictionary *parameters = @{@"UserId" : @(userId), @"Token" : token, @"OldPassword" : oldPassword, @"NewPassword" : aNewPassword};
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(parameters) responseClass:[DDPPofileResponse class] completionHandler:^(DDPPofileResponse *responseObj) {
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
    
    NSString *path = [[DDPMethod apiPath] ddp_appendingPathComponent:@"/register/resetpassword"];
    path = [path stringByAppendingFormat:@"?clientId=%@", CLIENT_ID];
    NSDictionary *parameters = @{@"UserName" : account, @"Email" : email,  @"Timestamp" : @((UInt64)([[NSDate date] timeIntervalSince1970]))};
    
    DDPBaseNetManagerSerializerType type = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseParseToJSON;
    
    return [[DDPBaseNetManager shareNetManager] POSTWithPath:path serializerType:type parameters:ddplay_encryption(parameters) completionHandler:^(DDPResponse *responseObj) {
        if (completionHandler) {
            completionHandler(responseObj.error);
        }
        
    }];
}

@end
