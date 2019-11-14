//
//  DDPToolsManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/8/16.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPToolsManager.h"
#import "DDPHTTPConnection.h"
#import "NSString+Tools.h"
#import <YYCache.h>
#import <HTTPServer.h>
#import "NSURL+Tools.h"
#import "DDPLoginViewController.h"
#if !DDPAPPTYPEISMAC
#import <TOSMBClient.h>
#import <Bugly/Bugly.h>
#import "DDPMediaThumbnailer.h"
#endif

static NSString *const tempImageKey = @"temp_image";
static NSString *const smbProgressBlockKey = @"smb_progress_block";
static NSString *const smbCompletionBlockKey = @"smb_completion_block";
static NSString *const parseMediaCompletionBlockKey = @"parse_media_completion_block";

@interface DDPToolsManager ()<TOSMBSessionDownloadTaskDelegate>

@end

@implementation DDPToolsManager
{
    dispatch_group_t _parseVideoGroup;
    dispatch_semaphore_t _semaphore;
    dispatch_queue_t _queue;
}

+ (instancetype)shareToolsManager {
    static dispatch_once_t onceToken;
    static DDPToolsManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[DDPToolsManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _parseVideoGroup = dispatch_group_create();
        _semaphore = dispatch_semaphore_create(2);
        _queue = dispatch_queue_create("com.dandanplay.parseVideo", nil);
    }
    return self;
}

- (void)dealloc {
    _parseVideoGroup = nil;
    _semaphore = nil;
    _queue = nil;
}

- (void)videoSnapShotWithModel:(DDPVideoModel *)model completion:(GetSnapshotAction)completion {
    #if !DDPAPPTYPEISMAC
    //防止重复获取缩略图
    if (model == nil || completion == nil || objc_getAssociatedObject(model, &tempImageKey)) return;
    
    objc_setAssociatedObject(model, &tempImageKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    let aMedia = [[VLCMedia alloc] initWithURL:model.fileURL];
    dispatch_group_async(_parseVideoGroup, _queue, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        DDPMediaThumbnailer *thumbnailer = [[DDPMediaThumbnailer alloc] initWithMedia:aMedia block:^(UIImage *image) {
            [[YYWebImageManager sharedManager].cache setImage:image forKey:model.quickHash];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(image);
                }
                
                objc_setAssociatedObject(model, &tempImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                dispatch_semaphore_signal(_semaphore);
            });
        }];
        
        [thumbnailer fetchThumbnail];
    });
#endif
}

+ (NSArray *)subTitleFileWithLocalURL:(NSURL *)url {
//    NSArray *danmakuTypes = ddp_danmakuTypes();
//    NSURL *aURL = [url URLByDeletingLastPathComponent];
    
    if (url == nil) {
        return @[];
    }
    
    NSString *fileName = [url.lastPathComponent stringByDeletingPathExtension];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:[url URLByDeletingLastPathComponent] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    NSMutableArray *subTitleFiles = [NSMutableArray array];
    
    for (NSURL *aURL in childFilesEnumerator) {
        NSString *tempFileName = [aURL.lastPathComponent stringByDeletingPathExtension];
        if (ddp_isDanmakuFile(aURL.absoluteString) && [tempFileName isEqualToString:fileName]) {
            [subTitleFiles addObject:aURL];
        }
    }
    
    return subTitleFiles;
}


#pragma mark - 本地文件
- (void)startDiscovererFileParentFolderWithChildrenFile:(DDPFile *)file
                                                   type:(PickerFileType)type
                                             completion:(GetFilesAction)completion {
    
    [self startDiscovererAllFileWithType:type completion:^(DDPFile *rootFile) {
        if (ddp_isRootFile(file)) {
            if (completion) {
                completion(rootFile);
            }
        }
        else {
            __block DDPFile *tempFile = nil;
            [rootFile.subFiles enumerateObjectsUsingBlock:^(__kindof DDPFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.fileURL.absoluteString hasSuffix:file.fileURL.absoluteString]) {
                    tempFile = obj;
                    *stop = YES;
                }
            }];
            
            if (completion) {
                completion(tempFile);
            }
        }
    }];
}

- (void)startDiscovererAllFileWithType:(PickerFileType)type
                            completion:(GetFilesAction)completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DDPFile *rootFile = ddp_getANewRootFile();
        
        if (rootFile.fileURL == nil) {
            completion(rootFile);
            return;
        }
        
        NSFileManager* manager = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:rootFile.fileURL includingPropertiesForKeys:@[NSURLFileResourceTypeRegular, NSURLFileResourceTypeDirectory] options:kNilOptions errorHandler:nil];
        
        NSMutableDictionary <NSString *, DDPFile *>*folderDic = [NSMutableDictionary dictionary];
        
        //用户自定义的目录 存储文件的quickHash
        NSMutableDictionary *folderCache = [DDPCacheManager shareCacheManager].folderCache;
        
        DDPFile *(^getParentFileAction)(NSURL *, NSString *) = ^(NSURL *parentURL, NSString *key) {
            if ([key isEqualToString:@"/"]) {
                return rootFile;
            }
            
            DDPFile *parentFile = folderDic[key];
            if (parentFile == nil) {
                parentFile = [[DDPFile alloc] initWithFileURL:parentURL type:DDPFileTypeFolder];
                parentFile.parentFile = rootFile;
                folderDic[key] = parentFile;
            }
            return parentFile;
        };
        
        for (NSURL *aURL in childFilesEnumerator) {
            if (((type & PickerFileTypeVideo) && ddp_isVideoFile(aURL.absoluteString)) ||
                ((type & PickerFileTypeSubtitle) && ddp_isSubTitleFile(aURL.absoluteString)) ||
                ((type & PickerFileTypeDanmaku) && ddp_isDanmakuFile(aURL.absoluteString))) {
                DDPFile *aFile = [[DDPFile alloc] initWithFileURL:aURL type:DDPFileTypeDocument];
                
                NSURL *parentURL = [aURL URLByDeletingLastPathComponent];
                NSString *parentFileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:parentURL.path error:nil] fileType];
                
                __block BOOL flag = NO;
                [folderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
                    //如果文件被用户转移过
                    if ([obj containsObject:aFile.videoModel.quickHash]) {
                        DDPFile *parentFile = getParentFileAction([rootFile.fileURL URLByAppendingPathComponent:key], key);
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
                    DDPFile *parentFile = getParentFileAction(parentURL, parentURL.lastPathComponent);
                    aFile.parentFile = parentFile;
                    [parentFile.subFiles addObject:aFile];
                }
            }
        }
        
        [rootFile.subFiles addObjectsFromArray:folderDic.allValues];
        
        [self sortFiles:rootFile.subFiles];

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(rootFile);
            });
        }
    });
}

- (void)startDiscovererFileWithType:(PickerFileType)type completion:(GetFilesAction)completion {
    if (completion == nil) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSMutableDictionary *folderDic = [NSMutableDictionary dictionary];
        
        DDPFile *rootFile = ddp_getANewRootFile();
        
        DDPFile *(^getParentFileAction)(NSURL *) = ^(NSURL *parentURL) {
            if ([parentURL isEqual:rootFile.fileURL]) {
                return rootFile;
            }
            
            NSString *key = parentURL.lastPathComponent;
            
            DDPFile *parentFile = folderDic[key];
            if (parentFile == nil) {
                parentFile = [[DDPFile alloc] initWithFileURL:parentURL type:DDPFileTypeFolder];
                parentFile.parentFile = rootFile;
                folderDic[key] = parentFile;
            }
            return parentFile;
        };
        
        if (rootFile.fileURL == nil) {
            completion(rootFile);
            return;
        }
        
        NSDirectoryEnumerator *childFilesEnumerator = [manager enumeratorAtURL:rootFile.fileURL includingPropertiesForKeys:nil options:kNilOptions errorHandler:nil];
        
        for (NSURL *url in childFilesEnumerator) {
            DDPFile *parentFile = getParentFileAction([url URLByDeletingLastPathComponent]);
            
            if (type == PickerFileTypeSubtitle) {
                if (ddp_isSubTitleFile(url.absoluteString)) {
                    DDPFile *file = [[DDPFile alloc] initWithFileURL:url type:DDPFileTypeDocument];
                    [parentFile.subFiles addObject:file];
                    file.parentFile = parentFile;
                }
            }
            else if (type == PickerFileTypeDanmaku) {
                if (ddp_isDanmakuFile(url.absoluteString)) {
                    DDPFile *file = [[DDPFile alloc] initWithFileURL:url type:DDPFileTypeDocument];
                    [parentFile.subFiles addObject:file];
                    file.parentFile = parentFile;
                }
            }
        }
        
        [rootFile.subFiles addObjectsFromArray:folderDic.allValues];
        
        [self sortFiles:rootFile.subFiles];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(rootFile);
        });
    });
}

- (void)moveFiles:(NSArray <DDPFile *>*)files toFolder:(NSString *)folderName {
    if (files.count == 0) return;
    
    //转移文件的hash数组
    NSMutableArray <NSString *>*hashArr = [NSMutableArray array];
    [files enumerateObjectsUsingBlock:^(DDPFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == DDPFileTypeFolder) {
            [obj.subFiles enumerateObjectsUsingBlock:^(DDPFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                [hashArr addObject:obj1.videoModel.quickHash];
            }];
        }
        else {
            [hashArr addObject:obj.videoModel.quickHash];
        }
    }];
    
    NSMutableDictionary <NSString *, NSMutableArray <NSString *>*>*folderCache = (NSMutableDictionary <NSString *, NSMutableArray <NSString *>*> *)[DDPCacheManager shareCacheManager].folderCache;
    
    
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
    
    [[DDPCacheManager shareCacheManager] setFolderCache:folderCache];
}

- (void)startSearchVideoWithRootFile:(DDPFile *)file
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
        DDPFile *obj = file.subFiles[i];
        if (obj.type == DDPFileTypeFolder) {
            [file.subFiles removeObject:obj];
            [file.subFiles addObjectsFromArray:obj.subFiles];
            i--;
        }
        else if ([pred evaluateWithObject:obj.fileURL.lastPathComponent]) {
            [arr addObject:obj];
        }
    }
    
    DDPFile *aFile = [[DDPFile alloc] initWithFileURL:nil type:DDPFileTypeFolder];
    aFile.subFiles = arr;
    completion(aFile);
}


#pragma mark - SMB
- (void)startDiscovererSMBFileWithParentFile:(DDPSMBFile *)parentFile
                                  completion:(GetSMBFilesAction)completion {
    [self startDiscovererSMBFileWithParentFile:parentFile fileType:PickerFileTypeAll completion:completion];
}

- (void)startDiscovererSMBFileWithParentFile:(DDPSMBFile *)parentFile
                                    fileType:(PickerFileType)fileType
                                  completion:(GetSMBFilesAction)completion {
#if DDPAPPTYPEIOS
    

    TOSMBSession *session = self.SMBSession;
    
    //根目录
    if (parentFile == nil) {
        parentFile = [[DDPSMBFile alloc] initWithFileURL:[NSURL URLWithString:@"/"] type:DDPFileTypeFolder];
        parentFile.relativeURL = [NSURL URLWithString:@"/"];
    }
    
    //对路径进行url解码
    NSString *aPath = [parentFile.relativeURL.absoluteString stringByURLDecode];
    
    [session requestContentsOfDirectoryAtFilePath:aPath success:^(NSArray <TOSMBSessionFile *>*files) {
        NSMutableArray <DDPFile *>*aFiles = [NSMutableArray array];
        NSMutableArray <DDPFile *>*aFolders = [NSMutableArray array];
        [files enumerateObjectsUsingBlock:^(TOSMBSessionFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DDPSMBFile *file = [[DDPSMBFile alloc] initWithSMBSessionFile:obj];
            file.parentFile = parentFile;
            if (obj.directory) {
                [aFolders addObject:file];
            }
            else {
                if (fileType == PickerFileTypeAll) {
                    [aFiles addObject:file];
                }
                else {
                    if(fileType & PickerFileTypeVideo && ddp_isVideoFile(obj.filePath)) {
                        [aFiles addObject:file];
                    }
                    else if(fileType & PickerFileTypeSubtitle && ddp_isSubTitleFile(obj.filePath)) {
                        [aFiles addObject:file];
                    }
                    else if(fileType & PickerFileTypeDanmaku && ddp_isDanmakuFile(obj.filePath)) {
                        [aFiles addObject:file];
                    }
                }
            }
        }];
        
        [aFiles sortUsingComparator:^NSComparisonResult(DDPSMBFile * _Nonnull obj1, DDPSMBFile * _Nonnull obj2) {
            return [obj2.name.pathExtension compare:obj1.name.pathExtension];
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
#endif
}

- (void)setSmbInfo:(DDPSMBInfo *)smbInfo {
#if DDPAPPTYPEIOS
    [self.SMBSession cancelAllRequests];
    _smbInfo = smbInfo;
    TOSMBSession *session = [[TOSMBSession alloc] init];
    session.password = _smbInfo.password;
    session.userName = _smbInfo.userName;
    session.hostName = _smbInfo.hostName;
    session.ipAddress = _smbInfo.ipAddress;
    //最大下载任务数
    session.maxTaskOperationCount = 5;
    self.SMBSession = session;
#endif
}

- (void)downloadSMBFile:(DDPSMBFile *)file
               progress:(void(^)(uint64_t totalBytesReceived, int64_t totalBytesToReceive, TOSMBSessionDownloadTask *task))progress
                 cancel:(void(^)(NSString *cachePath))cancel
             completion:(void(^)(NSString *destinationFilePath, NSError *error))completion {
    [self downloadSMBFile:file destinationPath:nil progress:progress cancel:cancel completion:completion];
}

- (void)downloadSMBFile:(DDPSMBFile *)file
        destinationPath:(NSString *)destinationPath
               progress:(void(^)(uint64_t totalBytesReceived, int64_t totalBytesToReceive, TOSMBSessionDownloadTask *task))progress
                 cancel:(void(^)(NSString *cachePath))cancel
             completion:(void(^)(NSString *destinationFilePath, NSError *error))completion {
#if DDPAPPTYPEIOS
    
    TOSMBSessionDownloadTask *task = [self.SMBSession downloadTaskForFileAtPath:file.sessionFile.filePath destinationPath:destinationPath delegate:self];
    objc_setAssociatedObject(task, &smbProgressBlockKey, progress, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(task, &smbCompletionBlockKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    @weakify(self)
    [task addObserverBlockForKeyPath:@"state" block:^(TOSMBSessionDownloadTask * _Nonnull obj, NSNumber * _Nonnull oldVal, NSNumber * _Nonnull newVal) {
        @strongify(self)
        if (!self) return;
        
        if (newVal.integerValue == TOSMBSessionTaskStateCancelled) {
            if (cancel) {
                cancel([obj valueForKey:@"tempFilePath"]);
                [obj removeObserverBlocks];
                [self removeAssociatedObjectWithTask:obj];
            }
        }
    }];
    
    [task resume];
#endif
}

#if DDPAPPTYPEIOS
#pragma mark TOSMBSessionDownloadTaskDelegate
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
- (void)task:(TOSMBSessionDownloadTask *)task didCompleteWithError:(NSError *)error; {
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

#endif

#pragma mark - PC端
- (void)startDiscovererFileWithLinkParentFile:(DDPLinkFile *)parentFile
                                     linkInfo:(DDPLinkInfo *)linkInfo
                                   completion:(GetLinkFilesAction)completion {
    if (completion == nil) return;
    
    if (linkInfo.selectedIpAdress.length == 0) {
        completion(nil, DDPErrorWithCode(DDPErrorCodeParameterNoCompletion));
        return;
    }
    
    [DDPLinkNetManagerOperation linkLibraryWithIpAdress:linkInfo.selectedIpAdress completionHandler:^(DDPLibraryCollection *responseObject, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        if (linkInfo != [DDPCacheManager shareCacheManager].linkInfo) {
            [DDPCacheManager shareCacheManager].linkInfo = linkInfo;
        }
        
        NSMutableDictionary <NSString *, NSMutableArray *>*dic = [NSMutableDictionary dictionary];
        
        [responseObject.collection enumerateObjectsUsingBlock:^(DDPLibrary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = obj.animeTitle;
            if (key.length == 0) {
                key = @"未分类";
            }
            
            if (dic[key] == nil) {
                dic[key] = [NSMutableArray array];
            }
            
            obj.fileType = DDPFileTypeDocument;
            [dic[key] addObject:[[DDPLinkFile alloc] initWithLibraryFile:obj]];
        }];
        
        DDPLinkFile *rootFile = ddp_getANewLinkRootFile();
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray <DDPLinkFile *>* _Nonnull obj, BOOL * _Nonnull stop) {
            DDPLibrary *aLibFile = [[DDPLibrary alloc] init];
            aLibFile.fileType = DDPFileTypeFolder;
            aLibFile.name = key;
            DDPLinkFile *aFile = [[DDPLinkFile alloc] initWithLibraryFile:aLibFile];
            [obj enumerateObjectsUsingBlock:^(DDPLinkFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                obj1.parentFile = aFile;
            }];
            
            [aFile.subFiles addObjectsFromArray:obj];
            aFile.parentFile = rootFile;
            [rootFile.subFiles addObject:aFile];
        }];
        
        __block DDPLinkFile *flagFile = nil;
        
        [rootFile.subFiles enumerateObjectsUsingBlock:^(DDPLinkFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.fileURL.absoluteString isEqualToString:parentFile.fileURL.absoluteString]) {
                flagFile = obj;
                completion(obj, error);
                *stop = YES;
            }
        }];
        
        if (flagFile == nil) {
            completion(rootFile, error);
        }
        else {
            completion(flagFile, error);
        }
    }];

}

- (void)startDiscovererFileWithLinkParentFile:(DDPLinkFile *)parentFile
                                   completion:(GetLinkFilesAction)completion {
    [self startDiscovererFileWithLinkParentFile:parentFile linkInfo:[DDPCacheManager shareCacheManager].linkInfo completion:completion];
}


#pragma mark - 私有方法
- (void)sortFiles:(NSMutableArray <DDPFile *>*)files {
    
    for (DDPFile *f in files) {
        if (f.subFiles.count) {
            [self sortFiles:f.subFiles];
        }
    }
    
    DDPFileSortType sortType = [DDPCacheManager shareCacheManager].fileSortType;
    [files sortUsingComparator:^NSComparisonResult(DDPFile * _Nonnull obj1, DDPFile * _Nonnull obj2) {
        if (sortType == 0) {
            if (obj1.type == DDPFileTypeFolder) {
                return NSOrderedAscending;
            }

            if (obj2.type == DDPFileTypeFolder) {
                return NSOrderedDescending;
            }

            return [obj1.name compare:obj2.name];
        }
        else {
            if (obj1.type == DDPFileTypeFolder) {
                return NSOrderedDescending;
            }

            if (obj2.type == DDPFileTypeFolder) {
                return NSOrderedAscending;
            }

            return [obj2.name compare:obj1.name];
        }
    }];
    
}

#if !DDPAPPTYPEISREVIEW
#pragma mark - HTTPServer

+ (HTTPServer *)shareHTTPServer {
    static dispatch_once_t onceToken;
    static HTTPServer *httpServer = nil;
    dispatch_once(&onceToken, ^{
        httpServer = [[HTTPServer alloc] init];
        [httpServer setType:@"_http._tcp."];
        NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
        [httpServer setDocumentRoot:docRoot];
        [httpServer setConnectionClass:[DDPHTTPConnection class]];
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
#endif


@end

