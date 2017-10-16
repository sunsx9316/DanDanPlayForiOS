//
//  LoginNetManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LoginNetManager.h"
#import <DanDanPlayEncrypt/DanDanPlayEncrypt.h>
#import "JHPofileResponse.h"

@implementation LoginNetManager

+ (NSURLSessionDataTask *)loginWithSource:(JHUserType)source
                                   userId:(NSString *)userId
                                    token:(NSString *)token
                        completionHandler:(void(^)(JHUser *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (userId.length == 0 || token.length == 0) {
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    NSString *sourceStr = jh_userTypeToString(source);
    NSDictionary *dic = @{@"Source" : sourceStr, @"UserId" : userId, @"AccessToken" : token};
    
    return [self POSTDataWithPath:[NSString stringWithFormat:@"%@/applogin?clientId=%@", API_PATH, CLIENT_ID] data:[[[dic jsonStringEncoded] dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            JHUser *user = [JHUser yy_modelWithJSON:model.responseObject];
            //登录失败
            if (user.needLogin == YES) {
                completionHandler(user, [NSError errorWithDomain:@"登录失败" code:DANDANPLAY_LOGIN_FAILE userInfo:@{NSLocalizedDescriptionKey : @"登录失败 请检查用户名和密码是否正确"}]);
            }
            else {
                completionHandler(user, model.error);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterWithRequest:(JHRegisterRequest *)request
                                 completionHandler:(void(^)(JHRegisterResponse *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (request.name.length == 0 || request.password.length == 0 || request.email.length == 0 || request.account.length == 0){
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    NSDictionary *dic = [request yy_modelToJSONObject];
    
    return [self POSTDataWithPath:[NSString stringWithFormat:@"%@/register?clientId=%@", API_PATH, CLIENT_ID] data:[[[dic jsonStringEncoded] dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            JHRegisterResponse *response = [JHRegisterResponse yy_modelWithJSON:model.responseObject];
            if (response.success == NO) {
                NSError *err = [NSError errorWithDomain:@"注册错误" code:DANDANPLAY_REGISTER_FAILE userInfo:@{NSLocalizedDescriptionKey : response.errorMessage.length ? response.errorMessage : @"注册错误"}];
                completionHandler(response, err);
            }
            else {
                completionHandler(response, nil);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterRelateToThirdPartyWithRequest:(JHRegisterRequest *)request
                                                   completionHandler:(void(^)(JHRegisterResponse *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (request.name.length == 0 || request.password.length == 0 || request.email.length == 0 || request.account.length == 0 || request.userId.length == 0 || request.token == 0){
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }

    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserName", @"Password", @"Email", @"ScreenName", @"UserId", @"Token"]];
    
    return [self POSTDataWithPath:[NSString stringWithFormat:@"%@/register/relate?clientId=%@", API_PATH, CLIENT_ID] data:[[[dic jsonStringEncoded] dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            JHRegisterResponse *response = [JHRegisterResponse yy_modelWithJSON:model.responseObject];
            if (response.success == NO) {
                NSError *err = [NSError errorWithDomain:@"注册错误" code:DANDANPLAY_REGISTER_FAILE userInfo:@{NSLocalizedDescriptionKey : response.errorMessage.length ? response.errorMessage : @"注册错误"}];
                completionHandler(response, err);
            }
            else {
                completionHandler(response, nil);
            }
        }
    }];
}

+ (NSURLSessionDataTask *)loginRegisterRelateOnlyWithRequest:(JHRegisterRequest *)request
                                           completionHandler:(void(^)(JHRegisterResponse *responseObject, NSError *error))completionHandler {
    if (completionHandler == nil) return nil;
    
    if (request.userId.length == 0 || request.token.length == 0 || request.account.length == 0 || request.password.length == 0){
        completionHandler(nil, jh_parameterNoCompletionError());
        return nil;
    }
    
    NSDictionary *dic = [[request yy_modelToJSONObject] dictionaryWithValuesForKeys:@[@"UserId", @"Token", @"UserName", @"Password"]];
    
    return [self POSTDataWithPath:[NSString stringWithFormat:@"%@/register/relateonly?clientId=%@", API_PATH, CLIENT_ID] data:[[[dic jsonStringEncoded] dataUsingEncoding:NSUTF8StringEncoding] encryptWithDandanplayType] completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            JHRegisterResponse *response = [JHRegisterResponse yy_modelWithJSON:model.responseObject];
            if (response.success == NO) {
                NSError *err = [NSError errorWithDomain:@"绑定错误" code:DANDANPLAY_BINDING_FAILE userInfo:@{NSLocalizedDescriptionKey : response.errorMessage.length ? response.errorMessage : @"绑定错误"}];
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
        completionHandler(jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self POSTWithPath:[NSString stringWithFormat:@"%@/user/profile", API_PATH] parameters:@{@"UserId" : @(userId), @"Token" : token, @"ScreenName" : userName} completionHandler:^(JHResponse *model) {
        JHPofileResponse *response = [JHPofileResponse yy_modelWithJSON:model.responseObject];
        if (model.error) {
            completionHandler(model.error);
        }
        else if (response.updateScreenNameSuccess == NO) {
            NSError *err = [NSError errorWithDomain:@"修改用户名错误" code:DANDANPLAY_UPDATE_USER_NAME_FAILE userInfo:@{NSLocalizedDescriptionKey : @"修改用户名失败"}];
            
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
        completionHandler(jh_parameterNoCompletionError());
        return nil;
    }
    
    return [self POSTWithPath:[NSString stringWithFormat:@"%@/user/profile", API_PATH] parameters:@{@"UserId" : @(userId), @"Token" : token, @"OldPassword" : oldPassword, @"NewPassword" : aNewPassword} completionHandler:^(JHResponse *model) {
        JHPofileResponse *response = [JHPofileResponse yy_modelWithJSON:model.responseObject];
        if (model.error) {
            completionHandler(model.error);
        }
        else if (response.updatePasswordSuccess == NO) {
            NSError *err = [NSError errorWithDomain:@"修改密码错误" code:DANDANPLAY_UPDATE_USER_NAME_FAILE userInfo:@{NSLocalizedDescriptionKey : @"修改密码失败 原密码错误或新密码不合要求"}];
            
            completionHandler(err);
        }
        else {
            completionHandler(nil);
        }
    }];
}

@end
