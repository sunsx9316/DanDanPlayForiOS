//
//  DDPMethod.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/12/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMethod.h"

NSString *DDPEpisodeTypeToString(DDPEpisodeType type) {
    switch (type) {
        case DDPEpisodeTypeAnimate:
            return @"TV动画";
        case DDPEpisodeTypeAnimateSpecial:
            return @"TV动画特别放送";
        case DDPEpisodeTypeOVA:
            return @"OVA";
        case DDPEpisodeTypePalgantong:
            return @"剧场版";
        case DDPEpisodeTypeMV:
            return @"音乐视频（MV）";
        case DDPEpisodeTypeWeb:
            return @"网络放送";
        case DDPEpisodeTypeOther:
            return @"其他";
        case DDPEpisodeTypeThreeDMovie:
            return @"三次元电影";
        case DDPEpisodeTypeThreeDTVPlayOrChineseAnimate:
            return @"三次元电视剧或国产动画";
        case DDPEpisodeTypeUnknow:
            return @"未知";
        default:
            break;
    }
};

NSError *DDPErrorWithCode(DDPErrorCode code) {
    switch (code) {
        case DDPErrorCodeParameterNoCompletion:
            return [[NSError alloc] initWithDomain:@"参数不完整" code:10000 userInfo:@{NSLocalizedDescriptionKey : @"参数不完整"}];
        case DDPErrorCodeCreatDownloadTaskFail:
            return [[NSError alloc] initWithDomain:@"任务创建失败" code:code userInfo:@{NSLocalizedDescriptionKey : @"任务创建失败"}];
        case DDPErrorCodeLoginFail:
            return [[NSError alloc] initWithDomain:@"登录失败" code:code userInfo:@{NSLocalizedDescriptionKey : @"登录失败 请检查用户名和密码是否正确"}];
        case DDPErrorCodeRegisterFail:
            return [[NSError alloc] initWithDomain:@"注册失败" code:code userInfo:@{NSLocalizedDescriptionKey : @"注册失败"}];
        case DDPErrorCodeUpdateUserNameFail:
            return [[NSError alloc] initWithDomain:@"更新用户名称失败" code:code userInfo:@{NSLocalizedDescriptionKey : @"更新用户名称失败"}];
        case DDPErrorCodeUpdateUserPasswordFail:
            return [[NSError alloc] initWithDomain:@"修改密码错误" code:code userInfo:@{NSLocalizedDescriptionKey : @"修改密码失败 原密码错误或新密码格式错误"}];
        case DDPErrorCodeBindingFail:
            return [[NSError alloc] initWithDomain:@"绑定失败" code:code userInfo:@{NSLocalizedDescriptionKey : @"绑定失败"}];
        case DDPErrorCodeObjectExist:
            return [[NSError alloc] initWithDomain:@"对象已存在" code:code userInfo:@{NSLocalizedDescriptionKey : @"对象已存在"}];
        default:
            return nil;
    }
};

UIKIT_EXTERN UIColor *DDPRGBColor(int r, int g, int b) {
    return DDPRGBAColor(r, g, b, 1);
}

UIKIT_EXTERN UIColor *DDPRGBAColor(int r, int g, int b, CGFloat a) {
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
}

@implementation DDPMethod

@end
