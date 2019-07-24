//
//  DDPSMBFileManagerPickerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSMBFileManagerPickerViewController.h"
#import "DDPBaseTableView.h"

#import "DDPFileManagerVideoTableViewCell.h"
#import "DDPFileManagerFolderLongViewCell.h"
#import "DDPEdgeButton.h"

@interface DDPSMBFileManagerPickerViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) UIImage *folderImg;
@end

@implementation DDPSMBFileManagerPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configRightItem];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if ([_file.fileURL isEqual:[NSURL URLWithString:@"/"]]) {
        self.navigationItem.title = @"根目录";
    }
    else {
        self.navigationItem.title = _file.name;
    }
    
    
    [self.tableView.mj_header beginRefreshing];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPSMBFile *file = _file.subFiles[indexPath.row];
    
    //文件
    if (file.type == DDPFileTypeDocument) {
        DDPFileManagerVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerVideoTableViewCell" forIndexPath:indexPath];
        if (cell.isFromCache == NO) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.selectedBackgroundView = [[UIView alloc] init];
            cell.tintColor = [UIColor ddp_mainColor];
            cell.fromCache = YES;
        }
        
        cell.titleLabel.text = file.name;
        if (_fileType == PickerFileTypeDanmaku && ddp_isDanmakuFile(file.fileURL.absoluteString)) {
            cell.fileTypeLabel.text = file.fileURL.pathExtension;
            [cell.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(36);
            }];
        }
        else if (_fileType == PickerFileTypeSubtitle && ddp_isSubTitleFile(file.fileURL.absoluteString)) {
            cell.fileTypeLabel.text = file.fileURL.pathExtension;
            [cell.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(36);
            }];
        }
        else {
            cell.fileTypeLabel.text = nil;
            [cell.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(0);
            }];
        }
        
        return cell;
    }
    
    //文件夹
    DDPFileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderLongViewCell"];
    if (cell.isFromCache == NO) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.tintColor = [UIColor ddp_mainColor];
        cell.fromCache = YES;
    }
    
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = nil;
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.detailLabel.textColor = [UIColor blackColor];
    cell.iconImgView.image = self.folderImg;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    DDPFile *file = _file.subFiles[indexPath.row];
//    if (file.type == DDPFileTypeDocument) {
//        return 60 + 30 * ddp_isPad();
//    }
//    return 70 + 30 * ddp_isPad();
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPSMBFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == DDPFileTypeFolder) {
        DDPSMBFileManagerPickerViewController *vc = [[DDPSMBFileManagerPickerViewController alloc] init];
        vc.file = file;
        vc.fileType = self.fileType;
        vc.selectedFileCallBack = self.selectedFileCallBack;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        if ((_fileType == PickerFileTypeDanmaku && ddp_isDanmakuFile(file.fileURL.absoluteString)) || (_fileType == PickerFileTypeSubtitle && ddp_isSubTitleFile(file.fileURL.absoluteString))) {
            if (self.selectedFileCallBack) {
                self.selectedFileCallBack(file);
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 私有方法
- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment_back_to_top"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)button {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 80;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:[DDPFileManagerVideoTableViewCell class] forCellReuseIdentifier:@"DDPFileManagerVideoTableViewCell"];
        [_tableView registerClass:[DDPFileManagerFolderLongViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderLongViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[DDPToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:self.file fileType:self.fileType completion:^(DDPSMBFile *file, NSError *error) {
                if (error) {
                    [self.view showWithError:error];
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

- (UIImage *)folderImg {
    if (_folderImg == nil) {
        _folderImg = [[UIImage imageNamed:@"comment_local_file_folder"] renderByMainColor];
    }
    return _folderImg;
}

@end
