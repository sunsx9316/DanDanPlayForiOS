//
//  ToolsManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/8/16.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "ToolsManager.h"
#import <YYCache.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <HTTPServer.h>
#import "DanDanPlayHTTPConnection.h"
#import "NSString+Tools.h"

static NSString *const thumbnailerBlockKey = @"thumbnailer_block";
static NSString *const tempImageKey = @"temp_image";
static NSString *const videoModelParseKey = @"video_model_parse";

@interface ToolsManager ()<VLCMediaThumbnailerDelegate>
@property (strong, nonatomic) NSMutableArray <VLCMediaThumbnailer *>*thumbnailers;
@end

@implementation ToolsManager

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

- (void)videoSnapShotWithModel:(VideoModel *)model completion:(getSnapshotAction)completion {
    //防止重复获取缩略图
    if (model == nil || completion == nil || objc_getAssociatedObject(model, &videoModelParseKey)) return;
    
    NSString *key = model.quickHash;
    if ([[YYWebImageManager sharedManager].cache containsImageForKey:key]) {
        [[YYWebImageManager sharedManager].cache getImageForKey:key withType:YYImageCacheTypeAll withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        }];
        return;
    }
    
    VLCMediaThumbnailer *thumb = [VLCMediaThumbnailer thumbnailerWithMedia:model.media andDelegate:self];
    //    thumb.snapshotPosition = 0.2;
    objc_setAssociatedObject(thumb, &thumbnailerBlockKey, ^(UIImage *image){
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    }, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    objc_setAssociatedObject(thumb, &tempImageKey, key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(model, &videoModelParseKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.thumbnailers addObject:thumb];
    [thumb fetchThumbnail];
}

- (void)startDiscovererVideoWithPath:(NSString *)path completion:(getVideosAction)completion {
    
    if (path.length == 0) {
        path = [[UIApplication sharedApplication] documentsPath];
    }
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(@[]);
            }
        });
        return;
    }
    
    [[CacheManager shareCacheManager].videoModels removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
        NSString *subpath = nil;
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        while ((subpath = [childFilesEnumerator nextObject]) != nil) {
            NSString* fileAbsolutePath = [path stringByAppendingPathComponent:subpath];
            NSDictionary *attributes = [defaultManager attributesOfItemAtPath:fileAbsolutePath error:nil];
            //过滤隐藏文件
            if ([attributes[NSFileExtensionHidden] boolValue] == NO) {
                VideoModel *model = [[VideoModel alloc] initWithFileURL:[NSURL fileURLWithPath:fileAbsolutePath]];
                [[CacheManager shareCacheManager].videoModels addObject:model];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([CacheManager shareCacheManager].videoModels);
            }
        });
    });
}


+ (instancetype)shareToolsManager {
    static dispatch_once_t onceToken;
    static ToolsManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ToolsManager alloc] init];
    });
    return manager;
}

+ (HTTPServer *)shareHTTPServer {
    static dispatch_once_t onceToken;
    static HTTPServer *httpServer = nil;
    dispatch_once(&onceToken, ^{
        httpServer = [[HTTPServer alloc] init];
        [httpServer setType:@"_http._tcp."];
        NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
        [httpServer setDocumentRoot:docRoot];
        [httpServer setInterface:[NSString getIPAddress]];
        [httpServer setPort:23333];
        [httpServer setConnectionClass:[DanDanPlayHTTPConnection class]];
    });
    return httpServer;
}

#pragma mark - VLCMediaThumbnailerDelegate
- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    getSnapshotAction action = objc_getAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey);
    if (action) {
        action(nil);
        objc_setAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self.thumbnailers removeObject:mediaThumbnailer];
}

- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    getSnapshotAction action = objc_getAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey);
    if (action) {
        UIImage *image = [UIImage imageWithCGImage:thumbnail];
        NSString *key = objc_getAssociatedObject(mediaThumbnailer, &tempImageKey);
        [[YYWebImageManager sharedManager].cache setImage:image forKey:key];
        action(image);
        objc_setAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self.thumbnailers removeObject:mediaThumbnailer];
}


#pragma mark - 懒加载

- (NSMutableArray<VLCMediaThumbnailer *> *)thumbnailers {
    if (_thumbnailers == nil) {
        _thumbnailers = [NSMutableArray array];
    }
    return _thumbnailers;
}




@end
