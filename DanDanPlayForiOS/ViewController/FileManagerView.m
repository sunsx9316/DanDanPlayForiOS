//
//  FileManagerView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerView.h"
#import <TOSMBSessionFile.h>

#define SHORT_TYPE_EDGE (5 + 5 * jh_isPad())

@interface FileManagerView ()<DZNEmptyDataSetSource>

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
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentFile = [CacheManager shareCacheManager].currentPlayVideoModel.file.parentFile;
        
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

- (void)refreshingWithAnimate:(BOOL)flag {
    if (flag) {
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
}

- (void)viewScrollToTop:(BOOL)flag {
    if (self.currentFile.parentFile) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:flag];
    }
    else {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:flag];
    }
}

- (void)reloadDataWithAnimate:(BOOL)flag {
    if (flag == NO) {
        [self.tableView reloadData];
    }
    else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        if ([_currentFile.parentFile.fileURL isEqual:[UIApplication sharedApplication].documentsURL]) {
            cell.titleLabel.text = @"返回根目录";
        }
        else {
            cell.titleLabel.text = @"返回上一级...";
        }
        
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.detailLabel.text = nil;
        cell.iconImgView.image = [UIImage imageNamed:@"file"];
        cell.maskView.hidden = YES;
        return cell;
    }
    
    JHFile *file = _currentFile.subFiles[indexPath.row];
    
    void(^setupCell)(FileManagerBaseViewCell *) = ^(FileManagerBaseViewCell *cell) {
        cell.maskView.hidden = !([self.selectedIndexs containsObject:file] && _isEditMode);
    };
    
    if (file.type == JHFileTypeDocument) {
        FileManagerFileLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFileLongViewCell" forIndexPath:indexPath];
        cell.model = file.videoModel;
        setupCell(cell);
        return cell;
    }
    
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.fileURL.lastPathComponent;
    cell.detailLabel.text = [NSString stringWithFormat:@"%lu个视频", (unsigned long)file.subFiles.count];
    cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
    setupCell(cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = _currentFile.subFiles[indexPath.row];
    [self deleteFiles:@[file]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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
    
    return 100 + 40 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //编辑模式
    if (_isEditMode && indexPath.section) {
        JHFile *file = _currentFile.subFiles[indexPath.row];
            if ([self.selectedIndexs containsObject:file]) {
                [self.selectedIndexs removeObject:file];
            }
            else {
                [self.selectedIndexs addObject:file];
            }
            [self reloadDataWithAnimate:NO];
    }
    else {
        if (indexPath.section == 0) {
            _currentFile = _currentFile.parentFile;
            [self touchCancelButton:nil];
            [self reloadDataWithAnimate:YES];
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
                [self reloadDataWithAnimate:YES];
            }
        }
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"(´_ゝ`)没有视频 点击刷新" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
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
            
            if ([textField.text containsString:@"/"]) {
                [MBProgressHUD showWithText:@"文件夹名称不合法！"];
                return;
            }
            
            [[ToolsManager shareToolsManager] moveFiles:self.selectedIndexs.allObjects toFolder:textField.text];
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
    if (_isEditMode == YES) {
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
                        aHUD.label.text = [NSString stringWithFormat:@"%ld/%ld", (long)index, (long)totalCount];
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
                    aHUD.label.text = [NSString stringWithFormat:@"%ld/%ld", (long)index, (long)totalCount];
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
        _tableView.estimatedRowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FileManagerFileLongViewCell class] forCellReuseIdentifier:@"FileManagerFileLongViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        [_tableView addGestureRecognizer:self.longPressGestureRecognizer];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererVideoWithFile:_currentFile completion:^(JHFile *file) {
                self->_currentFile = file;
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

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (_longPressGestureRecognizer == nil) {
        @weakify(self)
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithActionBlock:^(UILongPressGestureRecognizer * _Nonnull gesture) {
            @strongify(self)
            if (!self) return;
            
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                {
                    //播放视频样式不允许编辑
                    if (self->_currentFile.subFiles.count) {
                        self->_isEditMode = YES;
                        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(50);
                        }];
                        
                        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
                        if (indexPath) {
                            //将当前长按的cell加入选择
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
        }];
    }
    return _longPressGestureRecognizer;
}

@end
