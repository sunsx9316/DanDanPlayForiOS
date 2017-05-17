//
//  ToolsManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/8/16.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "ToolsManager.h"
#import "DanDanPlayHTTPConnection.h"
#import "NSString+Tools.h"
#import <YYCache.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <HTTPServer.h>
#import <MobileCoreServices/MobileCoreServices.h>

static const NSArray <NSString *>*_subtitles;

/**
 判断文件是不是视频
 
 @param aURL 路径
 @return 是不是视频
 */
CG_INLINE BOOL isVideoFile(NSURL *aURL) {
    CFStringRef fileExtension = (__bridge CFStringRef) [aURL pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    BOOL flag = UTTypeConformsTo(fileUTI, kUTTypeMovie);
    CFRelease(fileUTI);
    return flag;
};

CG_INLINE BOOL isSubTitleFile(NSURL *aURL) {
    static dispatch_once_t onceToken;
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
};

//CG_INLINE BOOL isExclude(NSString *name) {
//    return [name containsString:@"Inbox"];
//};

static NSString *const thumbnailerBlockKey = @"thumbnailer_block";
static NSString *const tempImageKey = @"temp_image";
static NSString *const videoModelParseKey = @"video_model_parse";

@interface ToolsManager ()<VLCMediaThumbnailerDelegate>
@property (strong, nonatomic) NSMutableArray <VLCMediaThumbnailer *>*thumbnailers;

@property (strong, nonatomic) NSMutableArray <JHFile *>*videoArray;
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

- (void)videoSnapShotWithModel:(VideoModel *)model completion:(GetSnapshotAction)completion {
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

- (void)startDiscovererVideoWithCompletion:(GetFilesAction)completion {
    
    JHFile *fileModel = [CacheManager shareCacheManager].rootFile;
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSMutableArray <JHFile *>*subFiles = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:fileModel.fileURL includingPropertiesForKeys:@[NSURLFileResourceTypeRegular, NSURLFileResourceTypeDirectory] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
        
        NSMutableDictionary <NSString *, JHFile *>*folderDic = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *folderCache = [CacheManager shareCacheManager].folderCache;
        for (NSURL *aURL in childFilesEnumerator) {
            if (isVideoFile(aURL)) {
                JHFile *aFile = [[JHFile alloc] init];
                aFile.type = JHFileTypeDocument;
                aFile.fileURL = aURL;
                //方便搜索
                [self.videoArray addObject:aFile];
                __block BOOL flag = NO;
                //文件夹名称字典
                [folderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
                    //hash数组
                    [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        if ([obj1 isEqualToString:aFile.videoModel.quickHash]) {
                            if (folderDic[key] == nil) {
                                JHFile *folder = [[JHFile alloc] init];
                                folder.type = JHFileTypeFolder;
                                folder.subFiles = [NSMutableArray array];
                                folder.parentFile = fileModel;
                                folder.fileURL = [NSURL fileURLWithPath:key];
                                folderDic[key] = folder;
                                [subFiles addObject:folder];
                            }
                            
                            [folderDic[key].subFiles addObject:aFile];
                            aFile.parentFile = folderDic[key];
                            flag = YES;
                            *stop1 = YES;
                        }
                    }];
                }];
                
                //根目录的视频直接加入根目录文件
                if (flag == NO) {
                    aFile.parentFile = fileModel;
                    [subFiles addObject:aFile];
                }
            }
        }
        
        [fileModel.subFiles addObjectsFromArray:folderCache.allValues];
        
        //把文件夹排在前面
        [subFiles sortUsingComparator:^NSComparisonResult(JHFile * _Nonnull obj1, JHFile * _Nonnull obj2) {
            return obj2.type - obj1.type;
        }];
        
        fileModel.subFiles = subFiles;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(fileModel);
            }
        });
    });
}

- (void)startDiscovererSubTitleWithCompletion:(GetFilesAction)completion {
    if (completion == nil) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        JHFile *rootFile = [[JHFile alloc] init];
        rootFile.subFiles = [NSMutableArray array];
        
        NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:[[UIApplication sharedApplication] documentsURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
        
        for (NSURL *url in childFilesEnumerator) {
            if (isSubTitleFile(url)) {
                JHFile *file = [[JHFile alloc] init];
                file.fileURL = url;
                [rootFile.subFiles addObject:file];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(rootFile);
        });
    });
}

- (void)addFiles:(NSArray <JHFile *>*)files toFolder:(NSString *)folderName {
    if (files.count == 0) return;
    
    NSMutableArray <NSString *>*hashArr = [NSMutableArray array];
    [files enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == JHFileTypeFolder) {
            [obj.subFiles enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                [hashArr addObject:obj1.videoModel.quickHash];
            }];
        }
        else {
            [hashArr addObject:obj.videoModel.quickHash];
        }
    }];
    
    NSMutableDictionary <NSString *, NSMutableArray <NSString *>*>*folderCache = (NSMutableDictionary <NSString *, NSMutableArray <NSString *>*> *)[CacheManager shareCacheManager].folderCache;
    NSMutableArray *arr = nil;
    
    if (folderCache == nil) {
        folderCache = [NSMutableDictionary dictionary];
    }
    
    //移除文件夹视频
    [folderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeObjectsInArray:hashArr];
    }];
    
    if (folderCache[folderName]) {
        arr = folderCache[folderName];
    }
    else {
        arr = [NSMutableArray array];
    }
    
    //将要添加的视频加入存储数组
    [arr addObjectsFromArray:hashArr];
    folderCache[folderName] = arr;
    
    [[CacheManager shareCacheManager] setFolderCache:(NSMutableDictionary <NSString *, NSArray <NSString *>*>*)folderCache];
}

- (void)startSearchVideoWithSearchKey:(NSString *)key completion:(GetFilesAction)completion {
    
    if (completion == nil) return;
    
    if (key.length == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"videoModel.fileNameWithPathExtension CONTAINS[c] %@", key];
    JHFile *aFile = [[JHFile alloc] init];
    aFile.type = JHFileTypeFolder;
    aFile.subFiles = [[self.videoArray filteredArrayUsingPredicate:pred] mutableCopy];
    completion(aFile);
    
    //    if (fileModel == nil) {
    //        fileModel = [[JHFile alloc] init];
    //        fileModel.fileURL = [[UIApplication sharedApplication] documentsURL];
    //    }
    
    //    NSFileManager* manager = [NSFileManager defaultManager];
    //    NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:fileModel.fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    //
    //    NSMutableArray *subFiles = [NSMutableArray array];
    //
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //        for (NSURL *aURL in childFilesEnumerator) {
    //            //            NSLog(@"%@", aURL);
    //
    //            if (isVideoFile(aURL) && [aURL.lastPathComponent rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
    //                JHFile *aFile = [[JHFile alloc] init];
    //                aFile.parentFile = fileModel;
    //                NSDictionary <NSFileAttributeKey, id>*attributes = [manager attributesOfItemAtPath:aURL.path error:nil];
    //                if ([attributes[NSFileType] isEqualToString:NSFileTypeRegular]) {
    //                    aFile.type = JHFileTypeDocument;
    //                }
    //                else if ([attributes[NSFileType] isEqualToString:NSFileTypeDirectory]) {
    //                    aFile.type = JHFileTypeFolder;
    //                }
    //
    //                aFile.fileURL = aURL;
    //                [subFiles addObject:aFile];
    //            }
    //        }
    //
    //        fileModel.subFiles = subFiles;
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            if (completion) {
    //                completion(fileModel);
    //            }
    //        });
    //    });
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
        [httpServer setConnectionClass:[DanDanPlayHTTPConnection class]];
        [httpServer setInterface:[NSString getIPAddress]];
        [httpServer setPort:23333];
    });
    return httpServer;
}

+ (void)resetHTTPServer {
    HTTPServer *httpServer = [self shareHTTPServer];
    [httpServer setInterface:[NSString getIPAddress]];
    [httpServer setPort:23333];
}

#pragma mark - VLCMediaThumbnailerDelegate
- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    GetSnapshotAction action = objc_getAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey);
    if (action) {
        action(nil);
        objc_setAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self.thumbnailers removeObject:mediaThumbnailer];
}

- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    GetSnapshotAction action = objc_getAssociatedObject(mediaThumbnailer, &thumbnailerBlockKey);
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

- (NSMutableArray<JHFile *> *)videoArray {
    if (_videoArray == nil) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

@end
