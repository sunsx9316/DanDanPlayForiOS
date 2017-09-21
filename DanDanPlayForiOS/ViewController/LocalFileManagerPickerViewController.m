//
//  LocalFileManagerPickerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LocalFileManagerPickerViewController.h"

#import "BaseTableView.h"
#import "FileManagerFolderPlayerListViewCell.h"
#import "FileManagerFolderLongViewCell.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import "NSURL+Tools.h"

@interface LocalFileManagerPickerViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation LocalFileManagerPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (jh_isRootFile(self.file)) {
        self.navigationItem.title = @"根目录";
    }
    else {
        self.navigationItem.title = self.file.name;
    }
    
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = self.file.subFiles[indexPath.row];
    //文件
    if (file.type == JHFileTypeDocument) {
        FileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = file.name;
        cell.titleLabel.textColor = [UIColor blackColor];
        return cell;
    }
    
    //文件夹
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = [NSString stringWithFormat:@"%ld个%@文件", file.subFiles.count, self.fileType == PickerFileTypeSubtitle ? @"字幕" : @"弹幕"];
    cell.iconImgView.image = [UIImage imageNamed:@"comment_local_file_folder"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = self.file.subFiles[indexPath.row];
    if (file.type == JHFileTypeDocument) {
        return [tableView fd_heightForCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" cacheByIndexPath:indexPath configuration:^(FileManagerFolderPlayerListViewCell *cell) {
            cell.titleLabel.text = file.name;
        }];
    }
    return 70 + 30 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = self.file.subFiles[indexPath.row];
    
    if (file.type == JHFileTypeDocument) {
        if (self.selectedFileCallBack) {
            self.selectedFileCallBack(file);
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        LocalFileManagerPickerViewController *vc = [[LocalFileManagerPickerViewController alloc] init];
        vc.file = file;
        vc.fileType = self.fileType;
        vc.selectedFileCallBack = self.selectedFileCallBack;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererVideoWithFile:self.file type:self.fileType completion:^(JHFile *file) {
                self.file = file;
                [self.tableView reloadData];
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
