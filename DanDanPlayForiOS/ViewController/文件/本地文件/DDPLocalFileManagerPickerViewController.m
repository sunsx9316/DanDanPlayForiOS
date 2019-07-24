//
//  DDPLocalFileManagerPickerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLocalFileManagerPickerViewController.h"

#import "DDPBaseTableView.h"
#import "DDPFileManagerFolderPlayerListViewCell.h"
#import "DDPFileManagerFolderLongViewCell.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import "NSURL+Tools.h"
#import "NSString+Tools.h"

@interface DDPLocalFileManagerPickerViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) UIImage *folderImg;
@end

@implementation DDPLocalFileManagerPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (ddp_isRootFile(self.file)) {
        self.navigationItem.title = @"根目录";
    }
    else {
        self.navigationItem.title = self.file.name;
    }
    
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPFile *file = self.file.subFiles[indexPath.row];
    //文件
    if (file.type == DDPFileTypeDocument) {
        DDPFileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = file.name;
        cell.titleLabel.textColor = [UIColor blackColor];
        return cell;
    }
    
    //文件夹
    DDPFileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = [NSString stringWithFormat:@"%@个%@文件", [NSString numberFormatterWithUpper:0 number:file.subFiles.count], self.fileType == PickerFileTypeSubtitle ? @"字幕" : @"弹幕"];
    cell.iconImgView.image = self.folderImg;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPFile *file = self.file.subFiles[indexPath.row];
    
    if (file.type == DDPFileTypeDocument) {
        if (self.selectedFileCallBack) {
            self.selectedFileCallBack(file);
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        DDPLocalFileManagerPickerViewController *vc = [[DDPLocalFileManagerPickerViewController alloc] init];
        vc.file = file;
        vc.fileType = self.fileType;
        vc.selectedFileCallBack = self.selectedFileCallBack;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 80;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DDPFileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[DDPFileManagerFolderLongViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderLongViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[DDPToolsManager shareToolsManager] startDiscovererFileParentFolderWithChildrenFile:self.file type:self.fileType completion:^(DDPFile *file) {
                self.file = file;
                [self.tableView reloadData];
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UIImage *)folderImg {
    if (_folderImg == nil) {
        _folderImg = [[UIImage imageNamed:@"comment_local_file_folder"] renderByMainColor];
    }
    return _folderImg;
}

@end
