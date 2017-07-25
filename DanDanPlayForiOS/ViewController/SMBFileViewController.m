//
//  SMBFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBFileViewController.h"
#import "FileManagerView.h"
#import "PlayNavigationController.h"
#import "MatchViewController.h"

#import "SMBVideoModel.h"
#import "BaseTableView.h"

#import "FileManagerFolderLongViewCell.h"
#import "FileManagerVideoTableViewCell.h"

@interface SMBFileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation SMBFileViewController
{
    JHSMBFile *_selectedFile;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (_file.parentFile) {
        self.navigationItem.title = _file.name;
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHSMBFile *file = _file.subFiles[indexPath.row];
    
    //文件
    if (file.type == JHFileTypeDocument) {
        FileManagerVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerVideoTableViewCell" forIndexPath:indexPath];
        cell.model = file;
        return cell;
    }
    
    //文件夹
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = nil;
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.detailLabel.textColor = [UIColor blackColor];
    cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JHFile *file = _file.subFiles[indexPath.row];
    if (file.type == JHFileTypeDocument) {
        return 60 + 30 * jh_isPad();
    }
    return 70 + 30 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JHSMBFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == JHFileTypeFolder) {
        SMBFileViewController *vc = [[SMBFileViewController alloc] init];
        vc.file = file;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        if (jh_isVideoFile(file.fileURL.absoluteString)) {
            
            void(^matchVideoAction)(NSString *) = ^(NSString *path) {
                NSString *hash = [[[NSFileHandle fileHandleForReadingAtPath:path] readDataOfLength: MEDIA_MATCH_LENGTH] md5String];
                [[CacheManager shareCacheManager] saveSMBFileHashWithHash:hash file:file.sessionFile];
                [self startMatchWithHash:hash];
            };
            
            _selectedFile = file;
            
            //查找是否获取过文件hash
            NSString *hash = [[CacheManager shareCacheManager] SMBFileHash:_selectedFile.sessionFile];
            if (hash.length) {
                [self startMatchWithHash:hash];
            }
            else {
                MBProgressHUD *_aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
                _aHUD.label.text = @"分析视频中...";
                
                [[ToolsManager shareToolsManager] downloadSMBFile:_selectedFile progress:^(uint64_t totalBytesReceived, int64_t totalBytesExpectedToReceive, TOSMBSessionDownloadTask *downloadTask) {
                    _aHUD.progress = totalBytesReceived * 1.0 / MIN(totalBytesExpectedToReceive, MEDIA_MATCH_LENGTH);
                    if (totalBytesReceived >= MEDIA_MATCH_LENGTH) {
                        [downloadTask cancel];
                    }
                    
                } cancel:^(NSString *cachePath) {
                    [_aHUD hideAnimated:YES];
                    matchVideoAction(cachePath);
                } completion:^(NSString *destinationFilePath, NSError *error) {
                    [_aHUD hideAnimated:YES];
                    
                    if (error) {
                        [MBProgressHUD showWithError:error];
                    }
                    else {
                        matchVideoAction(destinationFilePath);
                    }
                }];
            }
        }
    }
}

#pragma mark - 私有方法
- (void)startMatchWithHash:(NSString *)hash {
        
    SMBVideoModel *model = [[SMBVideoModel alloc] initWithFileURL:_selectedFile.sessionFile.fullURL hash:hash length:_selectedFile.sessionFile.fileSize];
    model.file = _selectedFile;
    
    void(^jumpToMatchVCAction)() = ^{
        MatchViewController *vc = [[MatchViewController alloc] init];
        vc.model = model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    if ([CacheManager shareCacheManager].openFastMatch) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = danmakusProgressToString(progress);
        } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
            model.danmakus = responseObject;
            [aHUD hideAnimated:NO];
            
            if (responseObject == nil) {
                jumpToMatchVCAction();
            }
            else {
                PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:model];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }];
    }
    else {
        jumpToMatchVCAction();
    }
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        [_tableView registerClass:[FileManagerVideoTableViewCell class] forCellReuseIdentifier:@"FileManagerVideoTableViewCell"];
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererFileWithSMBWithParentFile:self.file completion:^(JHSMBFile *file, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    self.file = file;
                    [self.tableView reloadData];
                }
                
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
