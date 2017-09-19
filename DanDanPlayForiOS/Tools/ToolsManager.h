//
//  ToolsManager.h
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/8/16.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "VideoModel.h"
#import "JhUser.h"
#import "JHFile.h"
#import "JHSMBFile.h"
#import "JHSMBInfo.h"
#import "JHLinkFile.h"

UIKIT_EXTERN DanDanPlayDanmakuType jh_danmakuStringToType(NSString *string);
UIKIT_EXTERN NSString *jh_danmakuTypeToString(DanDanPlayDanmakuType type);

/**
 判断路径是不是字幕

 @param aURL 路径
 @return 是不是字幕
 */
UIKIT_EXTERN BOOL jh_isSubTitleFile(NSString *aURL);
/**
 判断文件是不是视频
 
 @param aURL 路径
 @return 是不是视频
 */
UIKIT_EXTERN BOOL jh_isVideoFile(NSString *aURL);

/**
 判断路径是不是弹幕文件

 @param aURL 路径
 @return 是不是弹幕
 */
UIKIT_EXTERN BOOL jh_isDanmakuFile(NSString *aURL);


/**
 生成一个根目录文件夹

 @return 根目录
 */
UIKIT_EXTERN JHFile *jh_getANewRootFile();


/**
 生成一个PC的根目录对象

 @return 根目录
 */
UIKIT_EXTERN JHLinkFile *jh_getANewLinkRootFile();


/**
 判断路径是不是根目录

 @param url 路径
 @return    是不是根目录
 */
UIKIT_EXTERN BOOL jh_isRootFile(JHFile *file);

typedef void(^GetSnapshotAction)(UIImage *image);
typedef void(^GetFilesAction)(JHFile *file);
typedef void(^GetSMBFilesAction)(JHSMBFile *file, NSError *error);
typedef void(^GetLinkFilesAction)(JHLinkFile *file, NSError *error);

typedef NS_ENUM(NSUInteger, PickerFileType) {
    PickerFileTypeVideo = 1 << 0,
    PickerFileTypeSubtitle = 1 << 1,
    PickerFileTypeDanmaku = 1 << 2,
    PickerFileTypeAll = PickerFileTypeVideo | PickerFileTypeSubtitle | PickerFileTypeDanmaku
};

@class HTTPServer, TOSMBSession;
@interface ToolsManager : NSObject

+ (instancetype)shareToolsManager;

/**
 获取视频的截图

 @param model 视频模型
 @param completion 回调
 */
- (void)videoSnapShotWithModel:(VideoModel *)model completion:(GetSnapshotAction)completion;

+ (NSArray *)subTitleFileWithLocalURL:(NSURL *)url;

- (void)loginInViewController:(UIViewController *)viewController
                   completion:(void(^)(JHUser *user, NSError *err))completion;

#pragma mark - 本地文件
/**
 扫描视频模型
 */
- (void)startDiscovererVideoWithFile:(JHFile *)file
                                type:(PickerFileType)type
                          completion:(GetFilesAction)completion;


/**
 扫描文件

 @param type 文件类型
 @param completion 回调
 */
- (void)startDiscovererFileWithType:(PickerFileType)type completion:(GetFilesAction)completion;

/**
 移动文件到文件夹

 @param files 文件
 @param folderName 文件夹
 */
- (void)moveFiles:(NSArray <JHFile *>*)files toFolder:(NSString *)folderName;
/**
 搜索文件

 @param aURL 路径
 @param completion 回调
 */
- (void)startSearchVideoWithRootFile:(JHFile *)file
                           searchKey:(NSString *)key
                          completion:(GetFilesAction)completion;

#pragma mark - HTTPServer
+ (HTTPServer *)shareHTTPServer;
+ (void)resetHTTPServer;

#pragma mark - SMB
/**
 按照SMB协议扫描文件
 
 @param parentFile 路径
 @param completion 回调
 */
- (void)startDiscovererSMBFileWithParentFile:(JHSMBFile *)parentFile
                                      completion:(GetSMBFilesAction)completion;

/**
 按照SMB协议扫描文件

 @param parentFile 路径
 @param fileType 文件类型
 @param completion 回调
 */
- (void)startDiscovererSMBFileWithParentFile:(JHSMBFile *)parentFile
                                        fileType:(PickerFileType)fileType
                                      completion:(GetSMBFilesAction)completion;

/**
 下载smb文件

 @param file smb对象
 @param progress 进度
 @param cancel 取消回调
 @param completion 完成回调
 */

@property (strong, nonatomic) JHSMBInfo *smbInfo;

- (void)downloadSMBFile:(JHSMBFile *)file
                                     progress:(void(^)(uint64_t totalBytesReceived, int64_t totalBytesExpectedToReceive, TOSMBSessionDownloadTask *task))progress
                                       cancel:(void(^)(NSString *cachePath))cancel
                                   completion:(void(^)(NSString *destinationFilePath, NSError *error))completion;

/**
 下载smb文件

 @param file smb对象
 @param destinationPath 下载路径
 @param progress 进度
 @param cancel 取消回调
 @param completion 完成回调
 */
- (void)downloadSMBFile:(JHSMBFile *)file
        destinationPath:(NSString *)destinationPath
               progress:(void(^)(uint64_t totalBytesReceived, int64_t totalBytesToReceive, TOSMBSessionDownloadTask *task))progress
                 cancel:(void(^)(NSString *cachePath))cancel
             completion:(void(^)(NSString *destinationFilePath, NSError *error))completion;

@property (strong, nonatomic) TOSMBSession *SMBSession;

#pragma mark - PC端

/**
 获取PC文件

 @param parentFile 父文件
 @param completion 完成回掉
 */
- (void)startDiscovererFileWithLinkParentFile:(JHLinkFile *)parentFile
                                      completion:(GetLinkFilesAction)completion;
@end
