//
//  FileManagerPlayerListView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerPlayerListView.h"
#import "FileManagerFolderPlayerListViewCell.h"
#import "FileManagerVideoTableViewCell.h"

@implementation FileManagerPlayerListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"currentPlayVideoModel" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [self.tableView registerClass:[FileManagerVideoTableViewCell class] forCellReuseIdentifier:@"FileManagerVideoTableViewCell"];
        
        [self.tableView removeGestureRecognizer:self.longPressGestureRecognizer];
        
        @weakify(self)
        self.tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
                [[ToolsManager shareToolsManager] startDiscovererFileWithSMBWithParentFile:(JHSMBFile *)self.currentFile completion:^(JHFile *file, NSError *error) {
                    self.currentFile = file;
                    [self.tableView reloadData];
                    [self.tableView endRefreshing];
                }];
            }
            else {
                [[ToolsManager shareToolsManager] startDiscovererVideoWithFile:self.currentFile completion:^(JHFile *file) {
                    self.currentFile = file;
                    [self.tableView reloadData];
                    [self.tableView endRefreshing];
                }];
            }
        }];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPlayVideoModel"]) {
        [self.tableView reloadData];
    }
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"currentPlayVideoModel"];
}

- (void)setCurrentFile:(JHFile *)currentFile {
    [super setCurrentFile:currentFile];
    
    VideoModel *vm = [CacheManager shareCacheManager].currentPlayVideoModel;
    [currentFile.subFiles enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.videoModel isEqual:vm]) {
            //当前列表滚动到播放的视频位置
            [self.tableView scrollToRow:idx inSection:1 atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            *stop = YES;
        }
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
        //远程文件
        if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
            if ([self.currentFile.parentFile.fileURL.absoluteString isEqualToString:@"/"]) {
                cell.titleLabel.text = @"返回根目录";
            }
            else {
                cell.titleLabel.text = @"返回上一级...";
            }
        }
        else {
            if ([self.currentFile.parentFile.fileURL isEqual:[UIApplication sharedApplication].documentsURL]) {
                cell.titleLabel.text = @"返回根目录";
            }
            else {
                cell.titleLabel.text = @"返回上一级...";
            }
        }
        
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.detailLabel.text = nil;
        cell.iconImgView.image = [UIImage imageNamed:@"file"];
        cell.maskView.hidden = YES;
        return cell;
    }
    
    
    JHFile *file = self.currentFile.subFiles[indexPath.row];
    //文件
    if (file.type == JHFileTypeDocument) {
        //远程文件
        if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
            
            FileManagerVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerVideoTableViewCell" forIndexPath:indexPath];
            cell.model = (JHSMBFile *)file;
            //当前文件
            if ([file.videoModel.fileURL isEqual:[CacheManager shareCacheManager].currentPlayVideoModel.fileURL]) {
                cell.titleLabel.textColor = MAIN_COLOR;
            }
            else {
                cell.titleLabel.textColor = [UIColor whiteColor];
            }
            return cell;
        }
        
        FileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
        cell.model = file.videoModel;
        
        return cell;
    }
    
    //文件夹
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    //远程文件
    if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
        cell.titleLabel.text = file.name;
        cell.detailLabel.text = nil;
    }
    else {
        cell.titleLabel.text = file.fileURL.lastPathComponent;
        cell.detailLabel.text = [NSString stringWithFormat:@"%lu个视频", (unsigned long)file.subFiles.count];
    }
    
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.detailLabel.textColor = [UIColor whiteColor];
    cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //返回上一级
    if (indexPath.section == 0) {
        return 53 + 20 * jh_isPad();
    }
    
    JHFile *file = self.currentFile.subFiles[indexPath.row];
    if (file.type == JHFileTypeDocument) {
        return 60 + 30 * jh_isPad();
    }
    return 70 + 30 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.currentFile = self.currentFile.parentFile;
        [self reloadDataWithAnimate:YES];
        [self viewScrollToTop:NO];
    }
    else {
        JHFile *file = self.currentFile.subFiles[indexPath.row];
        
        if (file.type == JHFileTypeDocument) {
            if ([self.delegate respondsToSelector:@selector(managerView:didselectedModel:)]) {
                [self.delegate managerView:self didselectedModel:self.currentFile.subFiles[indexPath.item]];
            }
        }
        else if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
            [MBProgressHUD showLoadingInView:self text:nil];
            [[ToolsManager shareToolsManager] startDiscovererFileWithSMBWithParentFile:(JHSMBFile *)file completion:^(JHFile *aFile, NSError *error) {
                [MBProgressHUD hideLoading];
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    self.currentFile = file;
                    [self reloadDataWithAnimate:YES];
                    [self viewScrollToTop:NO];
                }
            }];
        }
        else {
            self.currentFile = file;
            [self reloadDataWithAnimate:YES];
            [self viewScrollToTop:NO];
        }
    }
}

@end
