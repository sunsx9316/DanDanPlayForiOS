//
//  FileManagerView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerView.h"
#import "FileManagerFileLongViewCell.h"
#import "FileManagerFolderLongViewCell.h"
#import "FileManagerFolderCollectionViewCell.h"
#import "FileManagerFolderPlayerListViewCell.h"

#import "BaseTableView.h"

#define SHORT_TYPE_EDGE (5 + 5 * jh_isPad())

@interface FileManagerView ()<UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UIButton *selectedAllButton;
@property (strong, nonatomic) UIButton *moveButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UICollectionViewFlowLayout *longStyleFlowLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *shortStyleFlowLayout;
@property (strong, nonatomic) NSMutableSet <JHFile *>*selectedIndexs;
@end

@implementation FileManagerView
{
    //记录当前路径
    JHFile *_tempFile;
    NSIndexPath *_currentIndex;
    BOOL _isEditMode;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentFile = [CacheManager shareCacheManager].currentPlayVideoModel.file.parentFile;
        [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"currentPlayVideoModel" options:NSKeyValueObservingOptionNew context:nil];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
        
        [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.top.equalTo(self.tableView.mas_bottom);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

//- (void)layoutSubviews {
//    [self.collectionView.collectionViewLayout invalidateLayout];
//    [super layoutSubviews];
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPlayVideoModel"]) {
        [self.tableView reloadData];
    }
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"currentPlayVideoModel"];
}

- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
    if (_searchKey.length == 0) {
        _currentFile = _tempFile;
        _tempFile = nil;
        [self.tableView reloadData];
    }
    else {
        if (_tempFile == nil) {
            _tempFile = _currentFile;
        }
        
        [[ToolsManager shareToolsManager] startSearchVideoWithSearchKey:searchKey completion:^(JHFile *file) {
            _currentFile = file;
            [self.tableView reloadData];
        }];
    }
}

- (void)reloadDataWithAnimate:(BOOL)flag {
    if (flag) {
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
}

- (void)setType:(FileManagerViewType)type {
    _type = type;
    if (self.superview) {
        [self.tableView reloadData];
    }
}

- (void)setCurrentFile:(JHFile *)currentFile {
    _currentFile = currentFile;
    if (self.superview) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (_currentFile.parentFile) {
            return 1;
        }
        return 0;
    }
    
    return _currentFile.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
        NSString *documentsPath = [UIApplication sharedApplication].documentsPath;
        NSString *path = [_currentFile.parentFile.fileURL.path stringByReplacingOccurrencesOfString:documentsPath withString:@""];
        if (path.length == 0) {
            path = @"返回根目录";
        }
        else {
            path = [@"返回上一级 ..." stringByAppendingPathComponent:path];
        }
        cell.titleLabel.text = path;
        cell.detailLabel.text = nil;
        cell.iconImgView.image = [UIImage imageNamed:@"file"];
        cell.maskView.hidden = YES;
        if (_type == FileManagerViewTypePlayerList) {
            cell.titleLabel.textColor = [UIColor whiteColor];
        }
        else {
            cell.titleLabel.textColor = [UIColor blackColor];
        }
        return cell;
    }
    
    JHFile *file = _currentFile.subFiles[indexPath.row];
    
    void(^setupCell)(FileManagerBaseViewCell *) = ^(FileManagerBaseViewCell *cell) {
        cell.maskView.hidden = !([self.selectedIndexs containsObject:file] && _isEditMode);
    };
    
    if (_type == FileManagerViewTypePlayerList) {
        if (file.type == JHFileTypeDocument) {
            FileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
            cell.model = file.videoModel;
            return cell;
        }
        
        FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = file.fileURL.lastPathComponent;
        cell.detailLabel.text = [NSString stringWithFormat:@"%ld个视频", file.subFiles.count];
        cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.detailLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    
    if (file.type == JHFileTypeDocument) {
        FileManagerFileLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFileLongViewCell" forIndexPath:indexPath];
        cell.model = file.videoModel;
        setupCell(cell);
        return cell;
    }
    
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.fileURL.lastPathComponent;
    cell.detailLabel.text = [NSString stringWithFormat:@"%ld个视频", file.subFiles.count];
    cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
    setupCell(cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = _currentFile.subFiles[indexPath.row];
    [self deleteFiles:@[file]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == FileManagerViewTypePlayerList || indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
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
    
    if (_type == FileManagerViewTypePlayerList) {
        JHFile *file = _currentFile.subFiles[indexPath.row];
        if (file.type == JHFileTypeDocument) {
            return 60 + 30 * jh_isPad();
        }
        return 70 + 30 * jh_isPad();
    }
    
    return 100 + 40 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEditMode && indexPath.section) {
        JHFile *file = _currentFile.subFiles[indexPath.row];
            if ([self.selectedIndexs containsObject:file]) {
                [self.selectedIndexs removeObject:file];
            }
            else {
                [self.selectedIndexs addObject:file];
            }
            [tableView reloadData];
    }
    else {
        if (indexPath.section == 0) {
            _currentFile = _currentFile.parentFile;
            [tableView reloadData];
        }
        else {
            JHFile *file = _currentFile.subFiles[indexPath.row];

            if (file.type == JHFileTypeDocument) {
                if ([self.delegate respondsToSelector:@selector(managerView:didselectedModel:)]) {
                    [self.delegate managerView:self didselectedModel:_currentFile.subFiles[indexPath.item]];
                }
            }
            else if (file.type == JHFileTypeFolder) {
                    _currentFile = file;
                    [tableView reloadData];
            }
        }
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"( ´_ゝ`)没有视频 点击刷新" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"通过iTunes、其它软件或者点击右上角的\"+\"号导入" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - 私有方法
- (void)touchSelectedAllButton:(UIButton *)button {
    button.selected = !button.isSelected;
    
    if (button.isSelected) {
        [_currentFile.subFiles enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.selectedIndexs addObject:obj];
        }];
    }
    else {
        [self.selectedIndexs removeAllObjects];
    }
    
    [self.tableView reloadData];
}

- (void)touchMoveButton:(UIButton *)button {
    if (self.selectedIndexs.count) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"移动到文件夹" message:nil preferredStyle:UIAlertControllerStyleAlert];
        @weakify(vc);
        [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
           textField.placeholder = @"文件夹名称 为空则移动至根目录";
        }];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(vc)
            if (!vc) return;
            
            UITextField *textField = vc.textFields.firstObject;
            
            [[ToolsManager shareToolsManager] addFiles:self.selectedIndexs.allObjects toFolder:textField.text];
                if (self.tableView.mj_header.refreshingBlock) {
                    self.tableView.mj_header.refreshingBlock();
                }
            
            [self touchCancelButton:nil];
        }]];
        
        [self.viewController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)touchDeleteButton:(UIButton *)button {
    [self deleteFiles:self.selectedIndexs.allObjects];
}

- (void)touchCancelButton:(UIButton *)button {
    [self.selectedIndexs removeAllObjects];
    _isEditMode = NO;
    [self.tableView reloadData];
    [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)deleteFiles:(NSArray <JHFile *>*)files {
    
    if (files.count == 0) return;
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认删除吗？" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        __block NSError *err;
        
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self];
        __block NSInteger index = 0;
        __block NSInteger totalCount = 0;
        [files enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == JHFileTypeFolder) {
                totalCount += obj.subFiles.count;
            }
            else {
                totalCount++;
            }
        }];
        
        [files enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == JHFileTypeFolder) {
                [obj.subFiles enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                    [fileManager removeItemAtURL:obj1.fileURL error:&err];
                    if (err) {
                        [aHUD hideAnimated:YES];
                        [MBProgressHUD showWithError:err];
                        *stop1 = YES;
                        *stop = YES;
                    }
                    else {
                        index++;
                        aHUD.label.text = [NSString stringWithFormat:@"%ld/%ld", index, totalCount];
                    }
                }];
                
                if (err == nil) {
                    [obj.parentFile.subFiles removeObject:obj];
                }
            }
            else {
                [fileManager removeItemAtURL:obj.fileURL error:&err];
                if (err == nil) {
                    [obj.parentFile.subFiles removeObject:obj];
                    index++;
                    aHUD.label.text = [NSString stringWithFormat:@"%ld/%ld", index, totalCount];
                }
                else {
                    [aHUD hideAnimated:YES];
                    [MBProgressHUD showWithError:err];
                    *stop = YES;
                }
            }
            
        }];
        
        [self touchCancelButton:nil];
        [aHUD hideAnimated:YES];
        [self.tableView reloadData];
    }]];
    
    [self.viewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 懒加载

- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FileManagerFileLongViewCell class] forCellReuseIdentifier:@"FileManagerFileLongViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        [_tableView registerClass:[FileManagerFolderCollectionViewCell class] forCellReuseIdentifier:@"FileManagerFolderCollectionViewCell"];
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        
        @weakify(self)
        [_tableView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithActionBlock:^(UILongPressGestureRecognizer * _Nonnull gesture) {
            @strongify(self)
            if (!self) return;

            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                {
                    //播放视频样式不允许编辑
                    if (self.type != FileManagerViewTypePlayerList && self->_currentFile.subFiles.count) {
                        self->_isEditMode = YES;
                        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(50);
                        }];
                        
                        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
                        if (indexPath) {
                            [self.selectedIndexs addObject:self->_currentFile.subFiles[indexPath.row]];
                            [self.tableView reloadData];
                        }



                        [UIView animateWithDuration:0.3 animations:^{
                            [self layoutIfNeeded];
                        } completion:nil];
                    }
                }
                    break;
                default:
                    break;
            }
            
        }]];
        
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;

            [[ToolsManager shareToolsManager] startDiscovererVideoWithCompletion:^(JHFile *file) {
                _currentFile = file;
                [self.tableView reloadData];
                [self.tableView endRefreshing];
            }];
        }];
        
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableSet<JHFile *> *)selectedIndexs {
    if (_selectedIndexs == nil) {
        _selectedIndexs = [NSMutableSet set];
    }
    return _selectedIndexs;
}

- (UIView *)editView {
    if (_editView == nil) {
        _editView = [[UIView alloc] init];
        _editView.backgroundColor = [UIColor whiteColor];
        _editView.clipsToBounds = YES;
        
        [_editView addSubview:self.selectedAllButton];
        [_editView addSubview:self.moveButton];
        [_editView addSubview:self.deleteButton];
        [_editView addSubview:self.cancelButton];
        
        [self.selectedAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_offset(0);
            make.width.height.mas_equalTo(@[self.moveButton, self.deleteButton, self.cancelButton]);
        }];
        
        [self.moveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectedAllButton.mas_right);
            make.centerY.equalTo(self.selectedAllButton);
        }];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.moveButton.mas_right);
            make.centerY.equalTo(self.selectedAllButton);
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.deleteButton.mas_right);
            make.centerY.equalTo(self.selectedAllButton);
            make.right.mas_offset(0);
        }];
        
        [self addSubview:_editView];
    }
    return _editView;
}

- (UIButton *)selectedAllButton {
    if (_selectedAllButton == nil) {
        _selectedAllButton = [[UIButton alloc] init];
        [_selectedAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [_selectedAllButton setImage:[UIImage imageNamed:@"cheak_mark"] forState:UIControlStateSelected];
        [_selectedAllButton addTarget:self action:@selector(touchSelectedAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedAllButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _selectedAllButton.titleLabel.font = NORMAL_SIZE_FONT;
        _selectedAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    return _selectedAllButton;
}

- (UIButton *)moveButton {
    if (_moveButton == nil) {
        _moveButton = [[UIButton alloc] init];
        [_moveButton setTitle:@"移动至..." forState:UIControlStateNormal];
        _moveButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_moveButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_moveButton addTarget:self action:@selector(touchMoveButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moveButton;
}

- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_deleteButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(touchDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_cancelButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(touchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
