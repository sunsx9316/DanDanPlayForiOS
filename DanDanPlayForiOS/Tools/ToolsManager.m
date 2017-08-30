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
#import <TOSMBSession.h>
#import <TOSMBSessionFile.h>
#import "NSURL+Tools.h"

CG_INLINE NSArray <NSString *>*jh_danmakuTypes() {
    static NSArray <NSString *>*_danmakuTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _danmakuTypes = @[@"XML"];
    });
    return _danmakuTypes;
};

UIKIT_EXTERN JHFile *jh_getANewRootFile() {
    return [[JHFile alloc] initWithFileURL:[[UIApplication sharedApplication] documentsURL] type:JHFileTypeFolder];
}

UIKIT_EXTERN DanDanPlayDanmakuType jh_danmakuStringToType(NSString *string) {
    if ([string isEqualToString: @"acfun"]) {
        return DanDanPlayDanmakuTypeAcfun;
    }
    else if ([string isEqualToString: @"bilibili"]) {
        return DanDanPlayDanmakuTypeBiliBili;
    }
    else if ([string isEqualToString: @"official"]) {
        return DanDanPlayDanmakuTypeOfficial;
    }
    return DanDanPlayDanmakuTypeUnknow;
}

UIKIT_EXTERN NSString *jh_danmakuTypeToString(DanDanPlayDanmakuType type) {
    switch (type) {
        case DanDanPlayDanmakuTypeAcfun:
            return @"acfun";
        case DanDanPlayDanmakuTypeBiliBili:
            return @"bilibili";
        case DanDanPlayDanmakuTypeOfficial:
            return @"official";
        default:
            break;
    }
    return @"";
}

UIKIT_EXTERN BOOL jh_isSubTitleFile(NSString *aURL) {
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

UIKIT_EXTERN BOOL jh_isVideoFile(NSString *aURL) {
    CFStringRef fileExtension = (__bridge CFStringRef) [aURL pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    BOOL flag = UTTypeConformsTo(fileUTI, kUTTypeMovie);
    CFRelease(fileUTI);
    return flag;
};

UIKIT_EXTERN BOOL jh_isDanmakuFile(NSString *aURL) {
    NSArray *danmakuTypes = jh_danmakuTypes();
    
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

UIKIT_EXTERN BOOL jh_isRootFile(NSURL *url) {
    return [url relationshipWithURL:[UIApplication sharedApplication].documentsURL] == NSURLRelationshipSame;
};

static NSString *const thumbnailerBlockKey = @"thumbnailer_block";
static NSString *const tempImageKey = @"temp_image";
static NSString *const smbProgressBlockKey = @"smb_progress_block";
static NSString *const smbCompletionBlockKey = @"smb_completion_block";

@interface ToolsManager ()<VLCMediaThumbnailerDelegate, TOSMBSessionDownloadTaskDelegate>
//@property (strong, nonatomic) NSMutableArray <JHFile *>*videoArray;
@property (strong, nonatomic) VLCMediaThumbnailer *thumbnailer;
@property (strong, nonatomic) NSMutableSet <VideoModel *>*parseVideo;
@end

@implementation ToolsManager
{
    VideoModel *_currentParseVideoModel;
}

+ (instancetype)shareToolsManager {
    static dispatch_once_t onceToken;
    static ToolsManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ToolsManager alloc] init];
    });
    return manager;
}

- (void)videoSnapShotWithModel:(VideoModel *)model completion:(GetSnapshotAction)completion {
    //防止重复获取缩略图
    if (model == nil || completion == nil || [self.parseVideo containsObject:model]) return;
    
    objc_setAssociatedObject(model, &thumbnailerBlockKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(model, &tempImageKey, model.quickHash, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self.parseVideo addObject:model];
    
    if (_thumbnailer == nil) {
        _thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:model.media andDelegate:self];
    }
    
    if (_currentParseVideoModel == nil) {
        _currentParseVideoModel = model;
        [self.thumbnailer fetchThumbnail];
    }
}

+ (NSArray *)subTitleFileWithLocalURL:(NSURL *)url {
    NSArray *danmakuTypes = jh_danmakuTypes();
    NSURL *aURL = [url URLByDeletingPathExtension];
    NSMutableArray *subTitleFiles = [NSMutableArray array];
    [danmakuTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *tempURL = [aURL URLByAppendingPathExtension:obj];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempURL.path]) {
            [subTitleFiles addObject:tempURL];
        }
    }];
    return subTitleFiles;
}

#pragma mark - 本地文件
- (void)startDiscovererVideoWithFile:(JHFile *)file
                                type:(PickerFileType)type
                          completion:(GetFilesAction)completion {
    //    JHFile *rootFile = [CacheManager shareCacheManager].rootFile;
    JHFile *rootFile = jh_getANewRootFile();
    //    [rootFile.subFiles removeAllObjects];
    
    //    if (type == PickerFileTypeAll) {
    //        [self.videoArray removeAllObjects];
    //    }
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:rootFile.fileURL includingPropertiesForKeys:@[NSURLFileResourceTypeRegular, NSURLFileResourceTypeDirectory] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    
    NSMutableDictionary <NSString *, JHFile *>*folderDic = [NSMutableDictionary dictionary];
    
    //用户自定义的目录 存储文件的quickHash
    NSMutableDictionary *folderCache = [CacheManager shareCacheManager].folderCache;
    
    JHFile *(^getParentFileAction)(NSURL *, NSString *) = ^(NSURL *parentURL, NSString *key) {
        if ([key isEqualToString:@"/"]) {
            return rootFile;
        }
        
        JHFile *parentFile = folderDic[key];
        if (parentFile == nil) {
            parentFile = [[JHFile alloc] initWithFileURL:parentURL type:JHFileTypeFolder];
            parentFile.parentFile = rootFile;
            folderDic[key] = parentFile;
        }
        return parentFile;
    };
    
    for (NSURL *aURL in childFilesEnumerator) {
        if (((type & PickerFileTypeVideo) && jh_isVideoFile(aURL.absoluteString)) ||
            ((type & PickerFileTypeSubtitle) && jh_isSubTitleFile(aURL.absoluteString)) ||
            ((type & PickerFileTypeDanmaku) && jh_isDanmakuFile(aURL.absoluteString))) {
            JHFile *aFile = [[JHFile alloc] initWithFileURL:aURL type:JHFileTypeDocument];
            
            NSURL *parentURL = [aURL URLByDeletingLastPathComponent];
            NSString *parentFileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:parentURL.path error:nil] fileType];
            
            __block BOOL flag = NO;
            [folderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
                //如果文件被用户转移过
                if ([obj containsObject:aFile.videoModel.quickHash]) {
                    JHFile *parentFile = getParentFileAction([rootFile.fileURL URLByAppendingPathComponent:key], key);
                    aFile.parentFile = parentFile;
                    [parentFile.subFiles addObject:aFile];
                    
                    flag = YES;
                    *stop = YES;
                }
            }];
            
            //用户已经转移 则不进行之后的操作
            if (flag == YES) continue;
            
            //根目录
            if ([parentURL relationshipWithURL:rootFile.fileURL] == NSURLRelationshipSame) {
                aFile.parentFile = rootFile;
                [rootFile.subFiles addObject:aFile];
            }
            //上层目录是文件夹则创建文件夹
            else if ([parentFileType isEqualToString:NSFileTypeDirectory]) {
                JHFile *parentFile = getParentFileAction(parentURL, parentURL.lastPathComponent);
                aFile.parentFile = parentFile;
                [parentFile.subFiles addObject:aFile];
            }
        }
    }
    
    [rootFile.subFiles addObjectsFromArray:folderDic.allValues];
    
    //把文件夹排在前面
    [rootFile.subFiles sortUsingComparator:^NSComparisonResult(JHFile * _Nonnull obj1, JHFile * _Nonnull obj2) {
        return obj2.type - obj1.type;
    }];
    
    if (jh_isRootFile(file.fileURL)) {
        if (completion) {
            completion(rootFile);
        }
    }
    else {
        __block JHFile *tempFile = nil;
        [rootFile.subFiles enumerateObjectsUsingBlock:^(__kindof JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.fileURL isEqual:file.fileURL]) {
                tempFile = obj;
                *stop = YES;
            }
        }];
        
        if (completion) {
            completion(tempFile);
        }
    }
}

- (void)startDiscovererFileWithType:(PickerFileType)type completion:(GetFilesAction)completion {
    if (completion == nil) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSMutableDictionary *folderDic = [NSMutableDictionary dictionary];
        
        JHFile *rootFile = jh_getANewRootFile();
        
        JHFile *(^getParentFileAction)(NSURL *) = ^(NSURL *parentURL) {
            if ([parentURL isEqual:rootFile.fileURL]) {
                return rootFile;
            }
            
            NSString *key = parentURL.lastPathComponent;
            
            JHFile *parentFile = folderDic[key];
            if (parentFile == nil) {
                parentFile = [[JHFile alloc] initWithFileURL:parentURL type:JHFileTypeFolder];
                parentFile.parentFile = rootFile;
                folderDic[key] = parentFile;
            }
            return parentFile;
        };
        
        NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:rootFile.fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
        
        for (NSURL *url in childFilesEnumerator) {
            JHFile *parentFile = getParentFileAction([url URLByDeletingLastPathComponent]);
            
            if (type == PickerFileTypeSubtitle) {
                if (jh_isSubTitleFile(url.absoluteString)) {
                    JHFile *file = [[JHFile alloc] initWithFileURL:url type:JHFileTypeDocument];
                    [parentFile.subFiles addObject:file];
                    file.parentFile = parentFile;
                }
            }
            else if (type == PickerFileTypeDanmaku) {
                if (jh_isDanmakuFile(url.absoluteString)) {
                    JHFile *file = [[JHFile alloc] initWithFileURL:url type:JHFileTypeDocument];
                    [parentFile.subFiles addObject:file];
                    file.parentFile = parentFile;
                }
            }
        }
        
        [rootFile.subFiles addObjectsFromArray:folderDic.allValues];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(rootFile);
        });
    });
}

- (void)moveFiles:(NSArray <JHFile *>*)files toFolder:(NSString *)folderName {
    if (files.count == 0) return;
    
    //转移文件的hash数组
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
    
    
    //从自定义文件夹缓存移除
    [folderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeObjectsInArray:hashArr];
    }];
    
    //加入根目录
    if (folderName.length == 0) {
        folderName = @"/";
    }
    
    NSMutableArray *subFiles = folderCache[folderName];
    if (subFiles == nil) {
        subFiles = [NSMutableArray array];
        folderCache[folderName] = subFiles;
    }
    
    [subFiles addObjectsFromArray:hashArr];
    
    [[CacheManager shareCacheManager] setFolderCache:folderCache];
}

- (void)startSearchVideoWithRootFile:(JHFile *)file
                           searchKey:(NSString *)key
                          completion:(GetFilesAction)completion {
    
    if (completion == nil) return;
    
    if (key.length == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", key];
    
    for (NSInteger i = 0; i < file.subFiles.count; ++i) {
        JHFile *obj = file.subFiles[i];
        if (obj.type == JHFileTypeFolder) {
            [file.subFiles removeObject:obj];
            [file.subFiles addObjectsFromArray:obj.subFiles];
            i--;
        }
        else if ([pred evaluateWithObject:obj.fileURL.lastPathComponent]) {
            [arr addObject:obj];
        }
    }
    
    JHFile *aFile = [[JHFile alloc] initWithFileURL:nil type:JHFileTypeFolder];
    aFile.subFiles = arr;
    completion(aFile);
}

#pragma mark - SMB

- (void)startDiscovererFileWithSMBWithParentFile:(JHSMBFile *)parentFile
                                      completion:(GetSMBFilesAction)completion {
    [self startDiscovererFileWithSMBWithParentFile:parentFile fileType:PickerFileTypeAll completion:completion];
}

- (void)startDiscovererFileWithSMBWithParentFile:(JHSMBFile *)parentFile
                                        fileType:(PickerFileType)fileType
                                      completion:(GetSMBFilesAction)completion {
    TOSMBSession *session = self.SMBSession;
    
    //根目录
    if (parentFile == nil) {
        parentFile = [[JHSMBFile alloc] initWithFileURL:[NSURL URLWithString:@"/"] type:JHFileTypeFolder];
        parentFile.relativeURL = [NSURL URLWithString:@"/"];
    }
    
    //对路径进行url解码
    NSString *aPath = [parentFile.relativeURL.absoluteString stringByURLDecode];
    
    [session requestContentsOfDirectoryAtFilePath:aPath success:^(NSArray <TOSMBSessionFile *>*files) {
        NSMutableArray <JHFile *>*aFiles = [NSMutableArray array];
        NSMutableArray <JHFile *>*aFolders = [NSMutableArray array];
        [files enumerateObjectsUsingBlock:^(TOSMBSessionFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JHSMBFile *file = [[JHSMBFile alloc] initWithSMBSessionFile:obj];
            file.parentFile = parentFile;
            if (obj.directory) {
                [aFolders addObject:file];
            }
            else {                
                if (fileType == PickerFileTypeAll) {
                    [aFiles addObject:file];
                }
                else {
                    if(fileType & PickerFileTypeVideo && jh_isVideoFile(obj.filePath)) {
                        [aFiles addObject:file];
                    }
                    else if(fileType & PickerFileTypeSubtitle && jh_isSubTitleFile(obj.filePath)) {
                        [aFiles addObject:file];
                    }
                    else if(fileType & PickerFileTypeDanmaku && jh_isDanmakuFile(obj.filePath)) {
                        [aFiles addObject:file];
                    }
                }
            }
        }];
        
        [aFolders addObjectsFromArray:aFiles];
        parentFile.subFiles = aFolders;
        if (completion) {
            completion(parentFile, nil);
        }
    } error:^(NSError *err) {
        if (completion) {
            completion(nil, err);
        }
    }];
}

- (void)setSmbInfo:(JHSMBInfo *)smbInfo {
    [self.SMBSession cancelAllRequests];
    _smbInfo = smbInfo;
    TOSMBSession *session = [[TOSMBSession alloc] init];
    session.password = _smbInfo.password;
    session.userName = _smbInfo.userName;
    session.hostName = _smbInfo.hostName;
    //最大下载任务数
    session.maxDownloadOperationCount = 5;
//    dispatch_queue_t serialQueue = dispatch_queue_create("com.dandanplay.smbdownload", DISPATCH_QUEUE_SERIAL);
//    [session setValue:serialQueue forKey:@"serialQueue"];
    self.SMBSession = session;
}

- (void)downloadSMBFile:(JHSMBFile *)file
               progress:(void(^)(uint64_t totalBytesReceived, int64_t totalBytesToReceive, TOSMBSessionDownloadTask *task))progress
                 cancel:(void(^)(NSString *cachePath))cancel
             completion:(void(^)(NSString *destinationFilePath, NSError *error))completion {
    [self downloadSMBFile:file destinationPath:nil progress:progress cancel:cancel completion:completion];
}

- (void)downloadSMBFile:(JHSMBFile *)file
        destinationPath:(NSString *)destinationPath
               progress:(void(^)(uint64_t totalBytesReceived, int64_t totalBytesToReceive, TOSMBSessionDownloadTask *task))progress
                 cancel:(void(^)(NSString *cachePath))cancel
             completion:(void(^)(NSString *destinationFilePath, NSError *error))completion {
    TOSMBSessionDownloadTask *task = [self.SMBSession downloadTaskForFileAtPath:file.sessionFile.filePath destinationPath:destinationPath delegate:self];
    objc_setAssociatedObject(task, &smbProgressBlockKey, progress, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(task, &smbCompletionBlockKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    @weakify(self)
    [task addObserverBlockForKeyPath:@"state" block:^(TOSMBSessionDownloadTask * _Nonnull obj, NSNumber * _Nonnull oldVal, NSNumber * _Nonnull newVal) {
        @strongify(self)
        if (!self) return;
        
        if (newVal.integerValue == TOSMBSessionDownloadTaskStateCancelled) {
            if (cancel) {
                cancel([obj valueForKey:@"tempFilePath"]);
                [obj removeObserverBlocks];
                [self removeAssociatedObjectWithTask:obj];
            }
        }
    }];
    
    [task resume];
}


#pragma mark - TOSMBSessionDownloadTaskDelegate
- (void)downloadTask:(TOSMBSessionDownloadTask *)downloadTask
       didWriteBytes:(uint64_t)bytesWritten
  totalBytesReceived:(uint64_t)totalBytesReceived
totalBytesExpectedToReceive:(int64_t)totalBytesToReceive {
    void(^progressAction)(uint64_t, int64_t, TOSMBSessionDownloadTask *) = objc_getAssociatedObject(downloadTask, &smbProgressBlockKey);
    if (progressAction) {
        progressAction(totalBytesReceived, totalBytesToReceive, downloadTask);
    }
}


/**
 下载成功回调
 
 @param downloadTask 任务
 @param destinationPath 路径
 */
- (void)downloadTask:(TOSMBSessionDownloadTask *)downloadTask didFinishDownloadingToPath:(NSString *)destinationPath {
    void(^completionAction)(NSString *destinationFilePath, NSError *error) = objc_getAssociatedObject(downloadTask, &smbCompletionBlockKey);
    if (completionAction) {
        completionAction(destinationPath, nil);
        [downloadTask removeObserverBlocks];
    }
    [self removeAssociatedObjectWithTask:downloadTask];
}


/**
 连接失败回调
 
 @param task 任务
 @param error 错误
 */
- (void)downloadTask:(TOSMBSessionDownloadTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        void(^completionAction)(NSString *destinationFilePath, NSError *error) = objc_getAssociatedObject(task, &smbCompletionBlockKey);
        if (completionAction) {
            completionAction(nil, error);
            [task removeObserverBlocks];
        }
        [self removeAssociatedObjectWithTask:task];
    }
}

- (void)removeAssociatedObjectWithTask:(TOSMBSessionDownloadTask *)task {
    objc_setAssociatedObject(task, &smbCompletionBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(task, &smbProgressBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - HTTPServer

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
    NSLog(@"超时......");
    GetSnapshotAction action = objc_getAssociatedObject(_currentParseVideoModel, &thumbnailerBlockKey);
    if (action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            action(nil);
        });
        objc_setAssociatedObject(_currentParseVideoModel, &thumbnailerBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(_currentParseVideoModel, &tempImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self.parseVideo removeObject:_currentParseVideoModel];
    
    if (self.parseVideo.count) {
        VideoModel *model = self.parseVideo.anyObject;
        _currentParseVideoModel = model;
        self.thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:model.media andDelegate:self];
        [self.thumbnailer fetchThumbnail];
    }
    else {
        _currentParseVideoModel = nil;
    }
}

- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    NSLog(@"成功......");
    GetSnapshotAction action = objc_getAssociatedObject(_currentParseVideoModel, &thumbnailerBlockKey);
    NSString *key = objc_getAssociatedObject(_currentParseVideoModel, &tempImageKey);
    UIImage *image = [UIImage imageWithCGImage:thumbnail];
    
    if (image) {
        [[YYWebImageManager sharedManager].cache setImage:image forKey:key];
    }
    
    if (action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            action(image);
        });
        objc_setAssociatedObject(_currentParseVideoModel, &thumbnailerBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(_currentParseVideoModel, &tempImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self.parseVideo removeObject:_currentParseVideoModel];
    
    if (self.parseVideo.count) {
        VideoModel *model = self.parseVideo.anyObject;
        _currentParseVideoModel = model;
        self.thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:model.media andDelegate:self];
        [self.thumbnailer fetchThumbnail];
    }
    else {
        _currentParseVideoModel = nil;
    }
}

#pragma mark - 懒加载
- (NSMutableSet<VideoModel *> *)parseVideo {
    if (_parseVideo == nil) {
        _parseVideo = [NSMutableSet set];
    }
    return _parseVideo;
}

//- (NSMutableArray<JHFile *> *)videoArray {
//    if (_videoArray == nil) {
//        _videoArray = [NSMutableArray array];
//    }
//    return _videoArray;
//}

@end
