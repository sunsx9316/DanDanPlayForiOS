//
//  FileManagerPickFileView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerPickFileView.h"
#import "FileManagerFolderPlayerListViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

@implementation FileManagerPickFileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        
        [self.tableView removeGestureRecognizer:self.longPressGestureRecognizer];
        
        @weakify(self)
        self.tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
                JHFile *file = nil;
                if (self.currentFile.type == JHFileTypeFolder) {
                    file = self.currentFile;
                }
                else {
                    file = self.currentFile.parentFile;
                }
                
                [[ToolsManager shareToolsManager] startDiscovererFileWithSMBWithParentFile:(JHSMBFile *)file fileType:_fileType completion:^(JHSMBFile *file, NSError *error) {
                    if (error) {
                        [MBProgressHUD showWithError:error];
                    }
                    else {
                        self.currentFile = file;
                        [self.tableView reloadData];
                    }
                    [self.tableView endRefreshing];
                }];
            }
            else {
                [[ToolsManager shareToolsManager] startDiscovererFileWithType:_fileType completion:^(JHFile *file) {
                    self.currentFile = file;
                    [self.tableView reloadData];
                    [self.tableView endRefreshing];
                }];
            }
        }];
    }
    return self;
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
        
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.detailLabel.text = nil;
        cell.iconImgView.image = [UIImage imageNamed:@"file"];
        cell.maskView.hidden = YES;
        return cell;
    }
    
    
    JHFile *file = self.currentFile.subFiles[indexPath.row];
    //其它
    if (file.type == JHFileTypeDocument) {
        FileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = file.name;
        cell.titleLabel.textColor = [UIColor blackColor];
        return cell;
    }
    
    //文件夹
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = nil;
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
        return [tableView fd_heightForCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" cacheByIndexPath:indexPath configuration:^(FileManagerFolderPlayerListViewCell *cell) {
            cell.titleLabel.text = file.name;
        }];
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
            [[ToolsManager shareToolsManager] startDiscovererFileWithSMBWithParentFile:(JHSMBFile *)file fileType:_fileType completion:^(JHSMBFile *file, NSError *error) {
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
