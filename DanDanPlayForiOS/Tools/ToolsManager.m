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
#import <TOSMBClient.h>
#import "NSURL+Tools.h"
#import <UMSocialCore/UMSocialCore.h>
#import <Bugly/Bugly.h>
#import "JHMediaThumbnailer.h"

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

UIKIT_EXTERN JHLinkFile *jh_getANewLinkRootFile() {
    JHLibrary *lib = [[JHLibrary alloc] init];
    lib.path = @"/";
    lib.fileType = JHFileTypeFolder;
    return [[JHLinkFile alloc] initWithLibraryFile:lib];
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

UIKIT_EXTERN BOOL jh_isRootFile(JHFile *file) {
    if ([file isKindOfClass:[JHLinkFile class]] || [file isKindOfClass:[JHSMBFile class]]) {
        return [file.fileURL.absoluteString isEqualToString:@"/"];
    }

    return [file.fileURL relationshipWithURL:[UIApplication sharedApplication].documentsURL] == NSURLRelationshipSame;
};

CG_INLINE NSString *UMErrorStringWithError(NSError *error) {
    switch (error.code) {
        case UMSocialPlatformErrorType_NotSupport:
            return @"客户端不支持该操作";
        case UMSocialPlatformErrorType_AuthorizeFailed:
            return @"授权失败";
        case UMSocialPlatformErrorType_ShareFailed:
            return @"分享失败";
        case UMSocialPlatformErrorType_RequestForUserProfileFailed:
            return @"请求用户信息失败";
        case UMSocialPlatformErrorType_ShareDataNil:
            return @"分享内容为空";
        case UMSocialPlatformErrorType_ShareDataTypeIllegal:
            return @"不支持该分享内容";
        case UMSocialPlatformErrorType_CheckUrlSchemaFail:
            return @"不支持该分享内容";
        case UMSocialPlatformErrorType_NotInstall:
            return @"应用未安装";
        case UMSocialPlatformErrorType_Cancel:
            return @"用户取消操作";
        case UMSocialPlatformErrorType_NotUsingHttps:
        case UMSocialPlatformErrorType_NotNetWork:
            return @"网络异常";
        case UMSocialPlatformErrorType_SourceError:
            return @"第三方错误";
        default:
            return @"未知错误";
            break;
    }
};

static NSString *const tempImageKey = @"temp_image";
static NSString *const smbProgressBlockKey = @"smb_progress_block";
static NSString *const smbCompletionBlockKey = @"smb_completion_block";

@interface ToolsManager ()<TOSMBSessionDownloadTaskDelegate>

@end

@implementation ToolsManager
{
    dispatch_group_t _parseVideoGroup;
    dispatch_semaphore_t _semaphore;
    dispatch_queue_t _queue;
}

+ (instancetype)shareToolsManager {
    static dispatch_once_t onceToken;
    static ToolsManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ToolsManager alloc] init];
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

- (void)videoSnapShotWithModel:(VideoModel *)model completion:(GetSnapshotAction)completion {
    
    //防止重复获取缩略图
    if (model == nil || completion == nil || objc_getAssociatedObject(model, &tempImageKey)) return;
    
    objc_setAssociatedObject(model, &tempImageKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_group_async(_parseVideoGroup, _queue, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        JHMediaThumbnailer *thumbnailer = [[JHMediaThumbnailer alloc] initWithMedia:model.media block:^(UIImage *image) {
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

- (void)loginInViewController:(UIViewController *)viewController
                    touchRect:(CGRect)touchRect
                barButtonItem:(UIBarButtonItem *)barButtonItem
                   completion:(void(^)(JHUser *user, NSError *err))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([CacheManager shareCacheManager].user == nil) {
            void(^loginWithTypeAction)(UMSocialPlatformType) = ^(UMSocialPlatformType platformType) {
                [MBProgressHUD showLoadingInView:viewController.view text:nil];
                [MBProgressHUD hideLoading];
                
                [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:viewController completion:^(id result, NSError *error) {
                    [MBProgressHUD hideLoading];
                    
                    if (error) {
                        [MBProgressHUD showWithText:UMErrorStringWithError(error) atView:viewController.view];
                        //上传错误
                        [Bugly reportError:error];
                        if (completion) {
                            completion(nil, error);
                        }
                    }
                    else {
                        UMSocialUserInfoResponse *resp = result;
                        [MBProgressHUD showLoadingInView:viewController.view text:@"登录中..."];
                        
                        [LoginNetManager loginWithSource:platformType == UMSocialPlatformType_Sina ? JHUserTypeWeibo : JHUserTypeQQ userId:resp.uid token:resp.accessToken completionHandler:^(JHUser *responseObject, NSError *error1) {
                            [MBProgressHUD hideLoading];
                            
                            if (error1) {
                                [MBProgressHUD showWithError:error1 atView:viewController.view];
                            }
                            else {
                                [CacheManager shareCacheManager].user = responseObject;
                            }
                            
                            if (completion) {
                                completion(responseObject, error1);
                            }
                        }];
                    }
                }];
            };
            
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"需要登录才能继续操作" message:@"请选择登录平台" preferredStyle:UIAlertControllerStyleActionSheet];
            [vc addAction:[UIAlertAction actionWithTitle:@"QQ" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                loginWithTypeAction(UMSocialPlatformType_QQ);
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"微博" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                loginWithTypeAction(UMSocialPlatformType_Sina);
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            if (jh_isPad()) {
                if (barButtonItem) {
                    vc.popoverPresentationController.barButtonItem = barButtonItem;
                }
                else {
                    vc.popoverPresentationController.sourceView = viewController.view;
                }
                vc.popoverPresentationController.sourceRect = touchRect;
            }
            
            [viewController presentViewController:vc animated:YES completion:nil];
        }        
    });
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
        
        if (obj1.type == JHFileTypeFolder) {
            return NSOrderedAscending;
        }
        
        if (obj2.type == JHFileTypeFolder) {
            return NSOrderedDescending;
        }
        
        return [obj1.name compare:obj2.name];
    }];
    
    if (jh_isRootFile(file)) {
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
- (void)startDiscovererSMBFileWithParentFile:(JHSMBFile *)parentFile
                                      completion:(GetSMBFilesAction)completion {
    [self startDiscovererSMBFileWithParentFile:parentFile fileType:PickerFileTypeAll completion:completion];
}

- (void)startDiscovererSMBFileWithParentFile:(JHSMBFile *)parentFile
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
        
        [aFiles sortUsingComparator:^NSComparisonResult(JHSMBFile * _Nonnull obj1, JHSMBFile * _Nonnull obj2) {
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
}

- (void)setSmbInfo:(JHSMBInfo *)smbInfo {
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
        
        if (newVal.integerValue == TOSMBSessionTaskStateCancelled) {
            if (cancel) {
                cancel([obj valueForKey:@"tempFilePath"]);
                [obj removeObserverBlocks];
                [self removeAssociatedObjectWithTask:obj];
            }
        }
    }];
    
    [task resume];
}

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

#pragma mark - PC端
- (void)startDiscovererFileWithLinkParentFile:(JHLinkFile *)parentFile
                                   completion:(GetLinkFilesAction)completion {
    if (completion == nil) return;
    
    [LinkNetManager linkLibraryWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress completionHandler:^(JHLibraryCollection *responseObject, NSError *error) {
        
        NSMutableDictionary <NSString *, NSMutableArray *>*dic = [NSMutableDictionary dictionary];
        
        [responseObject.collection enumerateObjectsUsingBlock:^(JHLibrary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = obj.animeTitle;
            if (key.length == 0) {
                key = @"未分类";
            }
            
            if (dic[key] == nil) {
                dic[key] = [NSMutableArray array];
            }
            
            obj.fileType = JHFileTypeDocument;
            [dic[key] addObject:[[JHLinkFile alloc] initWithLibraryFile:obj]];
        }];
        
        JHLinkFile *rootFile = jh_getANewLinkRootFile();
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray <JHLinkFile *>* _Nonnull obj, BOOL * _Nonnull stop) {
            JHLibrary *aLibFile = [[JHLibrary alloc] init];
            aLibFile.fileType = JHFileTypeFolder;
            aLibFile.name = key;
            JHLinkFile *aFile = [[JHLinkFile alloc] initWithLibraryFile:aLibFile];
            [obj enumerateObjectsUsingBlock:^(JHLinkFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                obj1.parentFile = aFile;
            }];
            
            [aFile.subFiles addObjectsFromArray:obj];
            aFile.parentFile = rootFile;
            [rootFile.subFiles addObject:aFile];
        }];
        
        __block JHLinkFile *flagFile = nil;
        
        [rootFile.subFiles enumerateObjectsUsingBlock:^(JHLinkFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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


@end
