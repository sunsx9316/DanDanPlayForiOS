//
//  DDPMethod.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/12/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMethod.h"
#import "NSURL+Tools.h"
#import <UMSocialCore/UMSocialCore.h>

static NSArray <NSString *>*ddp_danmakuTypes() {
    static NSArray <NSString *>*_danmakuTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _danmakuTypes = @[@"XML"];
    });
    return _danmakuTypes;
};


//UIKIT_EXTERN NSString *DDPEpisodeTypeToString(DDPEpisodeType type) {
//    switch (type) {
//        case DDPEpisodeTypeAnimate:
//            return @"TV动画";
//        case DDPEpisodeTypeAnimateSpecial:
//            return @"TV动画特别放送";
//        case DDPEpisodeTypeOVA:
//            return @"OVA";
//        case DDPEpisodeTypePalgantong:
//            return @"剧场版";
//        case DDPEpisodeTypeMV:
//            return @"音乐视频（MV）";
//        case DDPEpisodeTypeWeb:
//            return @"网络放送";
//        case DDPEpisodeTypeOther:
//            return @"其他";
//        case DDPEpisodeTypeThreeDMovie:
//            return @"三次元电影";
//        case DDPEpisodeTypeThreeDTVPlayOrChineseAnimate:
//            return @"三次元电视剧或国产动画";
//        case DDPEpisodeTypeUnknow:
//            return @"未知";
//        default:
//            break;
//    }
//};

UIKIT_EXTERN NSError *DDPErrorWithCode(DDPErrorCode code) {
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

UIKIT_EXTERN DDPFile *ddp_getANewRootFile() {
    return [[DDPFile alloc] initWithFileURL:[[UIApplication sharedApplication] documentsURL] type:DDPFileTypeFolder];
}

UIKIT_EXTERN DDPLinkFile *ddp_getANewLinkRootFile() {
    DDPLibrary *lib = [[DDPLibrary alloc] init];
    lib.path = @"/";
    lib.fileType = DDPFileTypeFolder;
    return [[DDPLinkFile alloc] initWithLibraryFile:lib];
}

UIKIT_EXTERN DDPDanmakuType ddp_danmakuStringToType(NSString *string) {
    if ([string isEqualToString: @"acfun"]) {
        return DDPDanmakuTypeAcfun;
    }
    else if ([string isEqualToString: @"bilibili"]) {
        return DDPDanmakuTypeBiliBili;
    }
    else if ([string isEqualToString: @"official"]) {
        return DDPDanmakuTypeOfficial;
    }
    return DDPDanmakuTypeUnknow;
}

UIKIT_EXTERN NSString *ddp_danmakuTypeToString(DDPDanmakuType type) {
    switch (type) {
        case DDPDanmakuTypeAcfun:
            return @"acfun";
        case DDPDanmakuTypeBiliBili:
            return @"bilibili";
        case DDPDanmakuTypeOfficial:
            return @"official";
        default:
            break;
    }
    return @"";
}

UIKIT_EXTERN BOOL ddp_isSubTitleFile(NSString *aURL) {
    static dispatch_once_t onceToken;
    static NSArray *_subtitles = nil;
    dispatch_once(&onceToken, ^{
        _subtitles = @[@"SSA", @"ASS", @"SMI", @"SRT", @"SUB", @"LRC", @"SST", @"TXT", @"XSS", @"PSB", @"SSB"];
    });
    
    NSString *pathExtension = aURL.pathExtension;
    __block BOOL flag = NO;
    [_subtitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj rangeOfString:pathExtension options:NSCaseInsensitiveSearch].location != NSNotFound) {
            flag = YES;
            *stop = YES;
        }
    }];
    
    return flag;
    
    //        CFStringRef fileExtension = (__bridge CFStringRef) [aURL pathExtension];
    //        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    //        BOOL flag = UTTypeConformsTo(fileUTI, kUTTypeText);
    //        CFRelease(fileUTI);
    //        return flag;
};

UIKIT_EXTERN BOOL ddp_isVideoFile(NSString *aURL) {
    NSString *pathExtension = [aURL pathExtension];
    
    if ([pathExtension compare:@"mkv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return true;
    }
    
    
    CFStringRef fileExtension = (__bridge CFStringRef) [aURL pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    BOOL flag = UTTypeConformsTo(fileUTI, kUTTypeMovie);
    CFRelease(fileUTI);
    return flag;
};

UIKIT_EXTERN BOOL ddp_isDanmakuFile(NSString *aURL) {
    NSArray *danmakuTypes = ddp_danmakuTypes();
    
    NSString *pathExtension = aURL.pathExtension;
    __block BOOL flag = NO;
    [danmakuTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj rangeOfString:pathExtension options:NSCaseInsensitiveSearch].location != NSNotFound) {
            flag = YES;
            *stop = YES;
        }
    }];
    
    return flag;
};

UIKIT_EXTERN BOOL ddp_isRootFile(DDPFile *file) {
    if ([file isKindOfClass:[DDPLinkFile class]] || [file isKindOfClass:[DDPSMBFile class]]) {
        return [file.fileURL.absoluteString isEqualToString:@"/"];
    }
    
    return [file.fileURL relationshipWithURL:[UIApplication sharedApplication].documentsURL] == NSURLRelationshipSame;
};

UIKIT_EXTERN BOOL ddp_isRootPath(NSString *path) {
    return [path isEqualToString:@"/"] || ([[NSURL fileURLWithPath:path] relationshipWithURL:[UIApplication sharedApplication].documentsURL] == NSURLRelationshipSame);
};

@implementation DDPMethod

+ (NSString *)apiDomain {
    if ([DDPCacheManager shareCacheManager].userDefineRequestDomain.length > 0) {
        return [DDPCacheManager shareCacheManager].userDefineRequestDomain;
    }
    return @"https://api.acplay.net/";
}

+ (NSString *)apiPath {
    return [[self apiDomain] ddp_appendingPathComponent:@"api/v1"];
}

+ (NSString *)apiNewPath {
    return [[self apiDomain] ddp_appendingPathComponent:@"/api/v2"];
}

BOOL ddp_isSmallDevice(void) {
    let height = [UIScreen mainScreen].bounds.size.height;
    if (ddp_isLandscape()) {
        return height <= 320.0;
    }
    return height <= 568.0;
}

BOOL ddp_isLandscape(void) {
    let size = [UIScreen mainScreen].bounds.size;
    return size.width > size.height;
}

BOOL ddp_isChatAppInstall(void) {
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
        return true;
    }
    
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Sina]) {
        return true;
    }
    
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        return true;
    }
    
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Tim]) {
        return true;
    }
    
    return false;
}

@end
