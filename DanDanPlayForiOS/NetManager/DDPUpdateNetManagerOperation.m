//
//  DDPUpdateNetManagerOperation.m
//  DDPlay_ToMac
//
//  Created by JimHuang on 2019/9/26.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPUpdateNetManagerOperation.h"
#import "DDPSharedNetManager.h"
#import "DDPNetManagerDefine.h"

@implementation DDPUpdateNetManagerOperation
+ (NSURLSessionDataTask *)checkUpdateInfoWithCompletionHandler:(DDP_ENTITY_RESPONSE_ACTION(DDPVersion))completionHandler {
    let path = [[DDPMethod checkVersionPath] stringByAppendingFormat:@"/iOS2Mac/check_version.json"];
    return [[DDPSharedNetManager sharedNetManager] GETWithPath:path serializerType:DDPBaseNetManagerSerializerTypeJSON parameters:nil completionHandler:^(__kindof DDPResponse *responseObj) {
        if (completionHandler) {
            if (responseObj.error) {
                completionHandler(nil, responseObj.error);
            }
            else {
                let model = [DDPVersion yy_modelWithJSON:responseObj.responseObject];
                completionHandler(model, responseObj.error);
            }
        }
    }];
}

+ (NSURLSessionTask *)downloadLatestAppWithURL:(NSURL *)url
         progressHandler:(void (^)(NSProgress *downloadProgress))progressHandler
                                 completionHandler:(DDP_ENTITY_RESPONSE_ACTION(NSURL))completionHandler {
    if (!url) {
        completionHandler(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return nil;
    }
    
    NSString *path = url.absoluteString;
    
    return [DDPSharedNetManager.sharedNetManager downloadTaskWithPath:path progress:progressHandler destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *downloadPath = UIApplication.sharedApplication.cachesPath;
        //自动下载路径不存在 则创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return [NSURL fileURLWithPath: [downloadPath stringByAppendingPathComponent:[response suggestedFilename]]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completionHandler(filePath, error);
    }];
}

@end
