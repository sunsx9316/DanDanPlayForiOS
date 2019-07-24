//
//  DDPFileManagerPlayerListView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerPlayerListView.h"
#import "DDPBaseTableView.h"

#import "DDPFileManagerFolderPlayerListViewCell.h"
#import "DDPFileManagerVideoTableViewCell.h"
#import "DDPFileManagerFolderLongViewCell.h"
#import "DDPFileManagerFileLongViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "UIImage+Tools.h"

@interface DDPFileManagerPlayerListView ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) UIImage *folderImg;
@end

@implementation DDPFileManagerPlayerListView
{
    DDPFile *_dataSourceFile;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.currentFile = [DDPCacheManager shareCacheManager].currentPlayVideoModel.file.parentFile;
        
         [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:@"currentPlayVideoModel" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPlayVideoModel"]) {
        [self.tableView reloadData];
    }
}

- (void)dealloc {
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:@"currentPlayVideoModel"];
}

- (void)setCurrentFile:(DDPFile *)currentFile {
    _currentFile = currentFile;
    [self.tableView reloadData];
}

- (void)scrollToCurrentFile {
    if ([self tableView:self.tableView numberOfRowsInSection:1]) {
        DDPVideoModel *vm = [DDPCacheManager shareCacheManager].currentPlayVideoModel;
        [_dataSourceFile.subFiles enumerateObjectsUsingBlock:^(DDPFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.videoModel isEqual:vm]) {
                //当前列表滚动到播放的视频位置
                [self.tableView scrollToRow:idx inSection:1 atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - 私有方法
- (void)reloadDataWithAnimate:(BOOL)flag {
    if (flag == NO) {
        [self.tableView reloadData];
    }
    else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)viewScrollToTop:(BOOL)flag {
    if (self.currentFile.parentFile) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:flag];
    }
    else {
        if ([self tableView:self.tableView numberOfRowsInSection:1]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:flag];
        }
    }
}

- (DDPSMBFile *)filterWithFile:(DDPSMBFile *)file {
    if ([file isKindOfClass:[DDPSMBFile class]]) {
        DDPSMBFile *tempParentFile = [[DDPSMBFile alloc] initWithSMBSessionFile:file.sessionFile];
        tempParentFile.parentFile = file.parentFile;
        tempParentFile.type = file.type;
        
        [file.subFiles enumerateObjectsUsingBlock:^(__kindof DDPFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == DDPFileTypeFolder || ddp_isVideoFile(obj.fileURL.absoluteString)) {
                [tempParentFile.subFiles addObject:obj];
            }
        }];
        
        return tempParentFile;
    }
    return file;
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"(´_ゝ`)没有视频 点击刷新" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DDPFileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderLongViewCell" forIndexPath:indexPath];
        if (ddp_isRootFile(self.currentFile.parentFile)) {
            cell.titleLabel.text = @"返回根目录";
        }
        else {
            cell.titleLabel.text = @"返回上一级...";
        }
        
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.detailLabel.text = nil;
        cell.iconImgView.image = [UIImage imageNamed:@"comment_player_list_back"];
        cell.maskView.hidden = YES;
        return cell;
    }
    
    
    DDPFile *file = _dataSourceFile.subFiles[indexPath.row];
    //文件
    if (file.type == DDPFileTypeDocument) {
        //远程文件
        if ([file isKindOfClass:[DDPSMBFile class]]) {
            
            DDPFileManagerVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerVideoTableViewCell" forIndexPath:indexPath];
            cell.model = (DDPSMBFile *)file;
            //当前文件
            if ([file.videoModel.fileURL isEqual:[DDPCacheManager shareCacheManager].currentPlayVideoModel.fileURL]) {
                cell.titleLabel.textColor = [UIColor ddp_mainColor];
            }
            else {
                cell.titleLabel.textColor = [UIColor whiteColor];
            }
            return cell;
        }
        
        DDPFileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
        cell.model = file.videoModel;
        
        return cell;
    }
    
    //文件夹
    DDPFileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderLongViewCell" forIndexPath:indexPath];
    //远程文件
    if ([file isKindOfClass:[DDPSMBFile class]]) {
        cell.titleLabel.text = file.name;
        cell.detailLabel.text = nil;
    }
    else {
        cell.titleLabel.text = file.name;
        cell.detailLabel.text = [NSString stringWithFormat:@"%lu个视频", (unsigned long)file.subFiles.count];
    }
    
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.detailLabel.textColor = [UIColor whiteColor];
    cell.iconImgView.image = self.folderImg;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _dataSourceFile = [self filterWithFile:(DDPSMBFile *)_currentFile];
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (_dataSourceFile.parentFile) {
            return 1;
        }
        return 0;
    }
    
    return _dataSourceFile.subFiles.count;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
    //返回上一级
//    if (indexPath.section == 0) {
//        return 53 + 20 * ddp_isPad();
//    }
//
//    DDPFile *file = _dataSourceFile.subFiles[indexPath.row];
//    if (file.type == DDPFileTypeDocument) {
//        return 60 + 30 * ddp_isPad();
//        return UITableViewAutomaticDimension;
//        if ([file isKindOfClass:[DDPSMBFile class]]) {
//            return [tableView fd_heightForCellWithIdentifier:@"DDPFileManagerVideoTableViewCell" cacheByIndexPath:indexPath configuration:^(DDPFileManagerVideoTableViewCell *cell) {
//                cell.model = (DDPSMBFile *)file;
//            }];
//        }
//        else {
//            return [tableView fd_heightForCellWithIdentifier:@"DDPFileManagerFolderPlayerListViewCell" cacheByIndexPath:indexPath configuration:^(DDPFileManagerFolderPlayerListViewCell *cell) {
//                cell.model = file.videoModel;
//            }];
//        }
//    }
//    return 70 + 30 * ddp_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        self.currentFile = _dataSourceFile.parentFile;
        [self reloadDataWithAnimate:YES];
        [self viewScrollToTop:NO];
    }
    else {
        DDPFile *file = _dataSourceFile.subFiles[indexPath.row];
        
        if (file.type == DDPFileTypeDocument) {
            if ([self.delegate respondsToSelector:@selector(managerView:didselectedModel:)]) {
                [self.delegate managerView:self didselectedModel:_dataSourceFile.subFiles[indexPath.item]];
            }
        }
        else if ([file isKindOfClass:[DDPSMBFile class]]) {
            [self showLoading];
            
            [[DDPToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:(DDPSMBFile *)file completion:^(DDPSMBFile *file, NSError *error) {
                [self hideLoading];
                if (error) {
                    [self showWithError:error];
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


#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DDPFileManagerFileLongViewCell class] forCellReuseIdentifier:@"DDPFileManagerFileLongViewCell"];
        [_tableView registerClass:[DDPFileManagerFolderLongViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderLongViewCell"];
        
        [_tableView registerClass:[DDPFileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[DDPFileManagerVideoTableViewCell class] forCellReuseIdentifier:@"DDPFileManagerVideoTableViewCell"];
        
        if ([self.currentFile isKindOfClass:[DDPSMBFile class]]) {
            @weakify(self)
            _tableView.mj_header = [MJRefreshHeader ddp_headerRefreshingCompletionHandler:^{
                @strongify(self)
                if (!self) return;
                
                [[DDPToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:(DDPSMBFile *)self.currentFile fileType:PickerFileTypeAll completion:^(DDPSMBFile *file, NSError *error) {
                    if (error) {
                        [self showWithError:error];
                    }
                    else {
                        self.currentFile = file;
                        [self.tableView reloadData];
                    }
                    
                    [self.tableView endRefreshing];
                }];
                
//                if ([self.currentFile isKindOfClass:[DDPSMBFile class]]) {
//                    [[DDPToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:(DDPSMBFile *)self.currentFile fileType:PickerFileTypeAll completion:^(DDPSMBFile *file, NSError *error) {
//                        if (error) {
//                            [self.view showWithError:error];
//                        }
//                        else {
//                            self.currentFile = file;
//                            [self.tableView reloadData];
//                        }
//                        
//                        [self.tableView endRefreshing];
//                    }];
//                }
//                else if ([self.currentFile isKindOfClass:[DDPLinkFile class]]) {
//                    [[DDPToolsManager shareToolsManager] startDiscovererFileWithLinkParentFile:(DDPLinkFile *)self.currentFile completion:^(DDPLinkFile *file, NSError *error) {
//                        if (error) {
//                            [self.view showWithError:error];
//                        }
//                        else {
//                            self.currentFile = file;
//                            [self.tableView reloadData];
//                        }
//                        
//                        [self.tableView endRefreshing];
//                    }];
//                }
//                else {
//                    [[DDPToolsManager shareToolsManager] startDiscovererVideoWithFile:self.currentFile type:PickerFileTypeVideo completion:^(DDPFile *file) {
//                        self.currentFile = file;
//                        [self.tableView reloadData];
//                        [self.tableView endRefreshing];
//                    }];
//                }
            }];
        }
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
