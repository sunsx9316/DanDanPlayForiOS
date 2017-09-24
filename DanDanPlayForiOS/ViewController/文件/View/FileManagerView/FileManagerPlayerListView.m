//
//  FileManagerPlayerListView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerPlayerListView.h"
#import "BaseTableView.h"

#import "FileManagerFolderPlayerListViewCell.h"
#import "FileManagerVideoTableViewCell.h"
#import "FileManagerFolderLongViewCell.h"
#import "FileManagerFileLongViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface FileManagerPlayerListView ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation FileManagerPlayerListView
{
    JHFile *_dataSourceFile;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.currentFile = [CacheManager shareCacheManager].currentPlayVideoModel.file.parentFile;
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"currentPlayVideoModel" options:NSKeyValueObservingOptionNew context:nil];
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
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"currentPlayVideoModel"];
}

- (void)setCurrentFile:(JHFile *)currentFile {
    _currentFile = currentFile;
    [self.tableView reloadData];
}

- (void)scrollToCurrentFile {
    if ([self tableView:self.tableView numberOfRowsInSection:1]) {
        VideoModel *vm = [CacheManager shareCacheManager].currentPlayVideoModel;
        [_dataSourceFile.subFiles enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (JHSMBFile *)filterWithFile:(JHSMBFile *)file {
    if ([file isKindOfClass:[JHSMBFile class]]) {
        JHSMBFile *tempParentFile = [[JHSMBFile alloc] initWithSMBSessionFile:file.sessionFile];
        tempParentFile.parentFile = file.parentFile;
        tempParentFile.type = file.type;
        
        [file.subFiles enumerateObjectsUsingBlock:^(__kindof JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == JHFileTypeFolder || jh_isVideoFile(obj.fileURL.absoluteString)) {
                [tempParentFile.subFiles addObject:obj];
            }
        }];
        
        return tempParentFile;
    }
    return file;
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"(´_ゝ`)没有视频 点击刷新" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
        if (jh_isRootFile(self.currentFile.parentFile)) {
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
    
    
    JHFile *file = _dataSourceFile.subFiles[indexPath.row];
    //文件
    if (file.type == JHFileTypeDocument) {
        //远程文件
        if ([file isKindOfClass:[JHSMBFile class]]) {
            
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
    if ([file isKindOfClass:[JHSMBFile class]]) {
        cell.titleLabel.text = file.name;
        cell.detailLabel.text = nil;
    }
    else {
        cell.titleLabel.text = file.name;
        cell.detailLabel.text = [NSString stringWithFormat:@"%lu个视频", (unsigned long)file.subFiles.count];
    }
    
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.detailLabel.textColor = [UIColor whiteColor];
    cell.iconImgView.image = [UIImage imageNamed:@"comment_local_file_folder"];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _dataSourceFile = [self filterWithFile:(JHSMBFile *)_currentFile];
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
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //返回上一级
    if (indexPath.section == 0) {
        return 53 + 20 * jh_isPad();
    }
    
    JHFile *file = _dataSourceFile.subFiles[indexPath.row];
    if (file.type == JHFileTypeDocument) {
//        return 60 + 30 * jh_isPad();
        if ([file isKindOfClass:[JHSMBFile class]]) {
            return [tableView fd_heightForCellWithIdentifier:@"FileManagerVideoTableViewCell" cacheByIndexPath:indexPath configuration:^(FileManagerVideoTableViewCell *cell) {
                cell.model = (JHSMBFile *)file;
            }];
        }
        else {
            return [tableView fd_heightForCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" cacheByIndexPath:indexPath configuration:^(FileManagerFolderPlayerListViewCell *cell) {
                cell.model = file.videoModel;
            }];
        }
    }
    return 70 + 30 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        self.currentFile = _dataSourceFile.parentFile;
        [self reloadDataWithAnimate:YES];
        [self viewScrollToTop:NO];
    }
    else {
        JHFile *file = _dataSourceFile.subFiles[indexPath.row];
        
        if (file.type == JHFileTypeDocument) {
            if ([self.delegate respondsToSelector:@selector(managerView:didselectedModel:)]) {
                [self.delegate managerView:self didselectedModel:_dataSourceFile.subFiles[indexPath.item]];
            }
        }
        else if ([file isKindOfClass:[JHSMBFile class]]) {
            [MBProgressHUD showLoadingInView:self text:nil];
            
            [[ToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:(JHSMBFile *)file completion:^(JHSMBFile *file, NSError *error) {
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


#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FileManagerFileLongViewCell class] forCellReuseIdentifier:@"FileManagerFileLongViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[FileManagerVideoTableViewCell class] forCellReuseIdentifier:@"FileManagerVideoTableViewCell"];
        
        if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
            @weakify(self)
            _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
                @strongify(self)
                if (!self) return;
                
                [[ToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:(JHSMBFile *)self.currentFile fileType:PickerFileTypeAll completion:^(JHSMBFile *file, NSError *error) {
                    if (error) {
                        [MBProgressHUD showWithError:error];
                    }
                    else {
                        self.currentFile = file;
                        [self.tableView reloadData];
                    }
                    
                    [self.tableView endRefreshing];
                }];
                
//                if ([self.currentFile isKindOfClass:[JHSMBFile class]]) {
//                    [[ToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:(JHSMBFile *)self.currentFile fileType:PickerFileTypeAll completion:^(JHSMBFile *file, NSError *error) {
//                        if (error) {
//                            [MBProgressHUD showWithError:error];
//                        }
//                        else {
//                            self.currentFile = file;
//                            [self.tableView reloadData];
//                        }
//                        
//                        [self.tableView endRefreshing];
//                    }];
//                }
//                else if ([self.currentFile isKindOfClass:[JHLinkFile class]]) {
//                    [[ToolsManager shareToolsManager] startDiscovererFileWithLinkParentFile:(JHLinkFile *)self.currentFile completion:^(JHLinkFile *file, NSError *error) {
//                        if (error) {
//                            [MBProgressHUD showWithError:error];
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
//                    [[ToolsManager shareToolsManager] startDiscovererVideoWithFile:self.currentFile type:PickerFileTypeVideo completion:^(JHFile *file) {
//                        self.currentFile = file;
//                        [self.tableView reloadData];
//                        [self.tableView endRefreshing];
//                    }];
//                }
            }];
        }
        
        
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
