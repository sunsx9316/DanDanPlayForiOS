//
//  NSString+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/25.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "NSString+Tools.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation NSString (Tools)

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (void)bilibiliAidWithPath:(NSString *)path complectionHandler:(void(^)(NSString *aid, NSString *page))completion {
    //http://www.bilibili.com/video/av46431/index_2.html
    if (!path) {
        completion(nil, nil);
    }
    
    NSString *aid;
    NSString *index;
    NSArray *arr = [path componentsSeparatedByString:@"/"];
    for (NSString *obj in arr) {
        if ([obj hasPrefix: @"av"]) {
            aid = [obj substringFromIndex: 2];
        }
        else if ([obj hasPrefix: @"index"]) {
            index = [[obj componentsSeparatedByString: @"."].firstObject componentsSeparatedByString: @"_"].lastObject;
        }
    }
    completion(aid, index);
}

+ (void)acfunAidWithPath:(NSString *)path complectionHandler:(void(^)(NSString *aid, NSString *index))completion {
    if (!path) {
        completion(nil, nil);
    }
    
    NSString *aid;
    NSString *index;
    NSArray *arr = [[path componentsSeparatedByString: @"/"].lastObject componentsSeparatedByString:@"_"];
    if (arr.count == 2) {
        index = arr.lastObject;
        aid = [arr.firstObject substringFromIndex: 2];
    }
    completion(aid, index);
}

- (BOOL)isSubtileFileWithVideoPath:(NSString *)videoPath {
    if (ddp_isSubTitleFile(self) == NO || videoPath.length == 0 || self.length < videoPath.length) {
        return NO;
    }
    
    NSString *subtitleName = [self stringByDeletingPathExtension];
    NSString *pathName = [videoPath stringByDeletingPathExtension];
    NSRange range = [subtitleName rangeOfString:pathName];
    
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (BOOL)isDanmakuFileWithVideoPath:(NSString *)videoPath {
    if (ddp_isDanmakuFile(self) == NO || videoPath.length == 0 || self.length < videoPath.length) {
        return NO;
    }
    
    NSString *danmakuName = [self stringByDeletingPathExtension];
    NSString *pathName = [videoPath stringByDeletingPathExtension];
    NSRange range = [danmakuName rangeOfString:pathName];
    
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (BOOL)isIpAdress {
    return [self matchesRegex:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionCaseInsensitive];
}

- (NSString *)pinYinIndex {
    NSMutableString *pinyin = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    NSString *tempStr = [pinyin uppercaseString];
    if (tempStr.length) {
        return [tempStr substringToIndex:1];
    }
    return @"#";
}

+ (NSString *)numberFormatterWithUpper:(NSUInteger)upper
                                number:(NSUInteger)number {
    if (upper == 0) {
        upper = 99;
    }
    
    if (number > upper) {
        return [NSString stringWithFormat:@"%lu+", (unsigned long)upper];
    }
    return [NSString stringWithFormat:@"%lu", (unsigned long)number];
}

- (BOOL)isRightAccount {
    return [self matchesRegex:[NSString stringWithFormat:@"^[a-zA-Z0-9_]{%d,%d}$", USER_ACCOUNT_MIN_COUNT, USER_ACCOUNT_MAX_COUNT] options:NSRegularExpressionCaseInsensitive];
}

- (BOOL)isRightPassword {
    return self.length >= USER_PASSWORD_MIN_COUNT && self.length <= USER_PASSWORD_MAX_COUNT;
}

- (BOOL)isRightEmail {
    return [self matchesRegex:@"^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$" options:NSRegularExpressionCaseInsensitive];
}

- (BOOL)isRightNickName {
    return self.length > 0 && self.length <= USER_NAME_MAX_COUNT;
}

- (BOOL)isMagnet {
#if DDPAPPTYPE != 1
    return [self containsString:@"magnet:?xt=urn:btih:"];
#else
    return false;
#endif
}

- (NSString *)ddp_appendingPathComponent:(NSString *)str {
    if (str.length == 0) {
        return self;
    }
    
    NSString *tempStr = self;
    
    //移除最后一个 ”/”
    if (self.length > 0 && [[self substringFromIndex:self.length - 1] isEqualToString:@"/"]) {
        tempStr = [self substringToIndex:self.length - 1];
    }
    
    //移除第一个 "/"
    if ([[str substringToIndex:1] isEqualToString:@"/"]) {
        str = [str substringFromIndex:1];
    }
    
    return [tempStr stringByAppendingFormat:@"/%@", str];
}

@end
