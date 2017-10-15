//
//  SMBFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBFileViewController.h"
//#import "FileManagerView.h"
#import "PlayNavigationController.h"
#import "MatchViewController.h"
#import "DownloadViewController.h"

#import "SMBVideoModel.h"
#import "JHBaseTableView.h"

#import "FileManagerFolderLongViewCell.h"
#import "FileManagerVideoTableViewCell.h"
#import "JHEdgeButton.h"
#import "SMBFileOprationView.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "UITableViewCell+Tools.h"

@interface SMBFileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) SMBFileOprationView *oprationView;
@end

@implementation SMBFileViewController
{
    JHSMBFile *_selectedFile;
    dispatch_group_t _group;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _group = dispatch_group_create();
    
    [self configRightItem];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.equalTo(self.oprationView.mas_top);
    }];
    
    [self.oprationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(self.view.mas_bottom);
    }];
    
    if (_file.parentFile) {
        self.navigationItem.title = _file.name;
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)dealloc {
    _group = nil;
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
        if (cell.isFromCache == NO) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.selectedBackgroundView = [[UIView alloc] init];
            cell.tintColor = MAIN_COLOR;
            cell.fromCache = YES;
        }
        cell.model = file;
        return cell;
    }
    
    //文件夹
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.tintColor = MAIN_COLOR;
        cell.fromCache = YES;
    }
    
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = nil;
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.detailLabel.textColor = [UIColor blackColor];
    cell.iconImgView.image = [UIImage imageNamed:@"comment_local_file_folder"];
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
    
    JHSMBFile *file = _file.subFiles[indexPath.row];
    if (file.type == JHFileTypeDocument) {
        return [tableView fd_heightForCellWithIdentifier:@"FileManagerVideoTableViewCell" cacheByIndexPath:indexPath configuration:^(FileManagerVideoTableViewCell *cell) {
            cell.model = file;
        }];
//        return 60 + 30 * jh_isPad();
    }
//    return 70 + 30 * jh_isPad();
    return UITableViewAutomaticDimension;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.isEditing) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
                        [MBProgressHUD showWithError:error atView:self.view];
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
    
    void(^jumpToMatchVCAction)(void) = ^{
        MatchViewController *vc = [[MatchViewController alloc] init];
        vc.model = model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    if ([CacheManager shareCacheManager].openFastMatch) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = jh_danmakusProgressToString(progress);
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

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:nil configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setTitle:@"下载" forState:UIControlStateNormal];
        [aButton setTitle:@"取消" forState:UIControlStateSelected];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)sender {
    BOOL flag = !self.tableView.isEditing;
    sender.selected = flag;
    [self.tableView setEditing:flag animated:YES];
    //显示
    if (flag) {
        [self.oprationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    //隐藏
    else {
        [self.oprationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.equalTo(self.view.mas_bottom);
        }];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)touchSelectedAllButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [_file.subFiles enumerateObjectsUsingBlock:^(__kindof JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)touchDownloadButton:(UIButton *)sender {
    NSArray <NSIndexPath *>*arr =  [self.tableView indexPathsForSelectedRows];
    
    if (arr.count == 0) return;
    
    NSMutableArray <TOSMBSessionDownloadTask *>*taskArr = [NSMutableArray array];
    
    MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeIndeterminate InView:nil];
    aHUD.label.text = @"处理中...";
    
    NSString *downloadPath = [UIApplication sharedApplication].documentsPath;
    
    dispatch_queue_t _queue = dispatch_queue_create("com.dandanplay.download", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    [arr enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JHSMBFile *file = _file.subFiles[obj.row];
        //文件夹
        if (file.type == JHFileTypeFolder) {
            dispatch_group_async(_group, _queue, ^{
                dispatch_group_enter(_group);
                [[ToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:file completion:^(JHSMBFile *file1, NSError *error1) {
                    [file1.subFiles enumerateObjectsUsingBlock:^(__kindof JHSMBFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        if (obj1.type == JHFileTypeDocument) {
                            //下载文件夹设置下载路径
                            NSString *fileName = [file.name stringByDeletingPathExtension];
                            NSString *destinationPath = [downloadPath stringByAppendingPathComponent:fileName];
                            if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath] == NO) {
                                [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];
                            }
                            
                            TOSMBSessionDownloadTask *aTask = [[ToolsManager shareToolsManager].SMBSession downloadTaskForFileAtPath:obj1.sessionFile.filePath destinationPath:destinationPath delegate:nil];
                            //设置文件大小
                            [aTask setValue:@(obj1.sessionFile.fileSize) forKey:@"countOfBytesExpectedToReceive"];
                            [taskArr addObject:aTask];
                        }
                    }];
                    dispatch_group_leave(_group);
                }];
            });
        }
        else {
            dispatch_group_async(_group, _queue, ^{
                TOSMBSessionDownloadTask *aTask = [[ToolsManager shareToolsManager].SMBSession downloadTaskForFileAtPath:file.sessionFile.filePath destinationPath:downloadPath delegate:nil];
                //设置文件大小
                [aTask setValue:@(file.sessionFile.fileSize) forKey:@"countOfBytesExpectedToReceive"];
                [taskArr addObject:aTask];
            });
        }
    }];
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        [taskArr enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj resume];
        }];
        
        [[CacheManager shareCacheManager] addSMBSessionDownloadTasks:taskArr];
        [aHUD hideAnimated:YES];
        
//        [MBProgressHUD showWithText:@"添加成功！"];
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"创建下载任务成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"下载列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DownloadViewController *vc = [[DownloadViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    });

    [self touchRightItem:self.navigationItem.rightBarButtonItem.customView];
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        _tableView.estimatedRowHeight = 60;
        [_tableView registerClass:[FileManagerVideoTableViewCell class] forCellReuseIdentifier:@"FileManagerVideoTableViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:self.file completion:^(JHSMBFile *file, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithText:@"网络错误"];
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

- (SMBFileOprationView *)oprationView {
    if (_oprationView == nil) {
        _oprationView = [[SMBFileOprationView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        [_oprationView.selectedAllButton addTarget:self action:@selector(touchSelectedAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [_oprationView.downloadButton addTarget:self action:@selector(touchDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_oprationView];
    }
    return _oprationView;
}

@end
