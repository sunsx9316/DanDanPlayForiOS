// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.

// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT

// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

//
//  LogHelper.m
//  iOSDemo
//
//  Created by caoshaokun on 16/11/30.
//  Copyright © 2016年 caoshaokun. All rights reserved.
//

#import "LogHelper.h"
#if !DDPAPPTYPEISMAC
#import "mars/xlog/xloggerbase.h"
#import "mars/xlog/xlogger.h"
#import "mars/xlog/appender.h"
#import <sys/xattr.h>

static NSUInteger g_processID = 0;
#endif

@implementation LogHelper

+ (void)logWithLevel:(DDPLogLevel)logLevel moduleName:(const char*)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName message:(NSString *)message {
#if DDPAPPTYPEISMAC
    NSLog(@"[module] %@ [file] %@ [line] %d [funcName] %@ [log] %@", [NSString stringWithUTF8String:moduleName], [NSString stringWithUTF8String:fileName], lineNumber, [NSString stringWithUTF8String:funcName], message);
#else
    XLoggerInfo info;
    info.level = (TLogLevel)logLevel;
    info.tag = moduleName;
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    xlogger_Write(&info, message.UTF8String);
#endif
}

+ (void)logWithLevel:(DDPLogLevel)logLevel moduleName:(const char*)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName format:(NSString *)format, ... {
    
    if ([self shouldLog:logLevel]) {
        va_list argList;
        va_start(argList, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
        [self logWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message];
        va_end(argList);
    }
}

+ (NSString *)logPath {
    NSString *documentsPath = [UIApplication.sharedApplication.documentsPath stringByAppendingPathComponent:@"log"];
    return documentsPath;
}

+ (void)setupLog {
#if !DDPAPPTYPEISMAC
    NSString *documentsPath = [self logPath];
    let attrName = "com.apple.MobileBackup";
    size_t attrValue = 1;
    setxattr(documentsPath.UTF8String, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
#if DEBUG
    xlogger_SetLevel(kLevelDebug);
    appender_set_console_log(true);
#else
    xlogger_SetLevel(kLevelInfo);
    appender_set_console_log(false);
#endif
    appender_open(kAppednerAsync, documentsPath.UTF8String, "DDPlay", "");
#endif
}

+ (void)deinitLog {
    #if !DDPAPPTYPEISMAC
    appender_close();
    #endif
}

+ (void)flush {
    #if !DDPAPPTYPEISMAC
    appender_flush();
    #endif
}

+ (BOOL)shouldLog:(DDPLogLevel)level {
    #if DDPAPPTYPEISMAC
        BOOL showLog = YES;
    #else
        BOOL showLog = (TLogLevel)level >= xlogger_Level();
    #endif
    return showLog;
}

@end
