//
//  FileManagerView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerView.h"
#import "FileManagerFileLongCollectionViewCell.h"
#import "FileManagerFolderLongCollectionViewCell.h"
#import "FileManagerFolderShortCollectionViewCell.h"
#import "FileManagerFolderPlayerListCollectionViewCell.h"

#import "BaseCollectionView.h"

#define SHORT_TYPE_EDGE (5 + 5 * jh_isPad())

@interface FileManagerView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource>
@property (strong, nonatomic) BaseCollectionView *collectionView;
@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UIButton *selectedAllButton;
//@property (strong, nonatomic) UIButton *moveButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UICollectionViewFlowLayout *longStyleFlowLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *shortStyleFlowLayout;
@property (strong, nonatomic) NSMutableSet <JHFile *>*selectedIndexs;
@end

@implementation FileManagerView
{
    JHFile *_currentFile;
    //记录当前路径
    JHFile *_tempFile;
    NSIndexPath *_currentIndex;
    BOOL _isEditMode;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"currentPlayVideoModel" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
        
        [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.top.equalTo(self.collectionView.mas_bottom);
        }];
        
        if (self.collectionView.mj_header.refreshingBlock) {
            self.collectionView.mj_header.refreshingBlock();
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)layoutSubviews {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [super layoutSubviews];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPlayVideoModel"]) {
        [self.collectionView reloadData];
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
        [self.collectionView reloadData];
    }
    else {
        if (_tempFile == nil) {
            _tempFile = _currentFile;
        }
        
        [[ToolsManager shareToolsManager] startSearchVideoWithFileModel:nil searchKey:searchKey completion:^(JHFile *file) {
            _currentFile = file;
            [self.collectionView reloadData];
        }];
    }
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)setType:(FileManagerViewType)type {
    _type = type;
    
    if (self.superview) {
        
        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            
        } completion:^(BOOL finished) {
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            if (_type == FileManagerViewTypeLong || _type == FileManagerViewTypePlayerList) {
                [self.collectionView setCollectionViewLayout:self.longStyleFlowLayout animated:YES];
            }
            else {
                [self.collectionView setCollectionViewLayout:self.shortStyleFlowLayout animated:YES];
            }
        }];
    }
    
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_isEditMode && indexPath.section) {
        JHFile *file = _currentFile.subFiles[indexPath.row];
            if ([self.selectedIndexs containsObject:file]) {
                [self.selectedIndexs removeObject:file];
            }
            else {
                [self.selectedIndexs addObject:file];
            }
            [collectionView reloadData];
    }
    else {
        if (indexPath.section == 0) {
            _currentFile = _currentFile.parentFile;
            [collectionView reloadData];
        }
        else {
            
            JHFile *file = _currentFile.subFiles[indexPath.row];
            
            if (file.type == JHFileTypeDocument) {
                if ([self.delegate respondsToSelector:@selector(managerView:didselectedModel:)]) {
                    [self.delegate managerView:self didselectedModel:_currentFile.subFiles[indexPath.item]];
                }
            }
            else if (file.type == JHFileTypeFolder) {
                [[ToolsManager shareToolsManager] startDiscovererVideoWithFileModel:file completion:^(JHFile *file) {
                    _currentFile = file;
                    [collectionView reloadData];
                }];
            }
        }
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        if (_currentFile.parentFile) {
            return 1;
        }
        return 0;
    }
    
    return _currentFile.subFiles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        FileManagerFolderLongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFolderLongCollectionViewCell" forIndexPath:indexPath];
        NSString *documentsPath = [UIApplication sharedApplication].documentsPath;
        NSString *path = [_currentFile.parentFile.fileURL.path stringByReplacingOccurrencesOfString:documentsPath withString:@""];
        if (path.length == 0) {
            path = @"返回根目录";
        }
        else {
            path = [@"返回上一级 ..." stringByAppendingPathComponent:path];
        }
        cell.titleLabel.text = path;
        cell.iconImgView.image = [UIImage imageNamed:@"file"];
        cell.maskView.hidden = YES;
        return cell;
    }
    
    JHFile *file = _currentFile.subFiles[indexPath.row];
    
    void(^setupCell)(FileManagerBaseCollectionViewCell *) = ^(FileManagerBaseCollectionViewCell *cell) {
        cell.maskView.hidden = !([self.selectedIndexs containsObject:file] && _isEditMode);
    };
    
    if (_type == FileManagerViewTypePlayerList) {
        if (file.type == JHFileTypeDocument) {
            FileManagerFolderPlayerListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFolderPlayerListCollectionViewCell" forIndexPath:indexPath];
            cell.model = file.videoModel;
            return cell;
        }
        
        FileManagerFolderLongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFolderLongCollectionViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = file.fileURL.lastPathComponent;
        cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
        cell.titleLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    else if (_type == FileManagerViewTypeLong) {
        if (file.type == JHFileTypeDocument) {
            FileManagerFileLongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFileLongCollectionViewCell" forIndexPath:indexPath];
            cell.model = file.videoModel;
            setupCell(cell);
            return cell;
        }
        
        FileManagerFolderLongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFolderLongCollectionViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = file.fileURL.lastPathComponent;
        cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
        setupCell(cell);
        return cell;
        
    }
    
    if (file.type == JHFileTypeDocument) {
        FileManagerFileLongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFileLongCollectionViewCell" forIndexPath:indexPath];
        cell.model = file.videoModel;
        setupCell(cell);
        return cell;
    }
    
    FileManagerFolderShortCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileManagerFolderShortCollectionViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.fileURL.lastPathComponent;
    setupCell(cell);
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //返回上一级
    if (indexPath.section == 0) {
        return CGSizeMake(self.width, 53 + 20 * jh_isPad());
    }
    
    if (_type == FileManagerViewTypeLong) {
        return CGSizeMake(self.width, 100 + 40 * jh_isPad());
    }
    
    if (_type == FileManagerViewTypePlayerList) {
        JHFile *file = _currentFile.subFiles[indexPath.row];
        if (file.type == JHFileTypeDocument) {
            return CGSizeMake(self.width, 60 + 30 * jh_isPad());
        }
        return CGSizeMake(self.width, 70 + 30 * jh_isPad());
    }
    
    float width = (self.width - 4 * SHORT_TYPE_EDGE) / 3 - 1;
    return CGSizeMake(width, width);
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
    
    [self.collectionView reloadData];
}

- (void)touchMoveButton:(UIButton *)button {
    if (self.selectedIndexs.count) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"移动到文件夹" message:nil preferredStyle:UIAlertControllerStyleAlert];
        @weakify(vc);
        [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
           textField.placeholder = @"文件夹名称";
        }];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(vc)
            if (!vc) return;
            
            UITextField *textField = vc.textFields.firstObject;
            
            if (textField.text.length == 0) return;
            
            NSURL *tempURL = [self->_currentFile.fileURL URLByAppendingPathComponent:textField.text];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            __block NSError *err;
            if ([fileManager fileExistsAtPath:tempURL.path] == NO) {
                [fileManager createDirectoryAtPath:tempURL.path withIntermediateDirectories:YES attributes:nil error:&err];
                if (err) {
                    [MBProgressHUD showWithError:err];
                    return;
                }
            }
            
            MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self];
            __block NSInteger index = 0;
            [self.selectedIndexs enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, BOOL * _Nonnull stop) {
                NSURL *toURL = [tempURL URLByAppendingPathComponent:obj.fileURL.lastPathComponent];
                [fileManager moveItemAtURL:obj.fileURL toURL:toURL error:&err];
                if (err == nil) {
                    [obj.parentFile.subFiles removeObject:obj];
                    index++;
                    aHUD.label.text = [NSString stringWithFormat:@"%ld/%ld", index, self.selectedIndexs.count];
                }
                else {
                    [aHUD hideAnimated:YES];
                    [MBProgressHUD showWithError:err];
                    *stop = YES;
                }
            }];
            
            //没有错误
            if (index == self.selectedIndexs.count) {
                [aHUD hideAnimated:YES];
                if (self.collectionView.mj_header.refreshingBlock) {
                    self.collectionView.mj_header.refreshingBlock();
                }
            }
        }]];
        
        [self.viewController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)touchDeleteButton:(UIButton *)button {
    if (self.selectedIndexs.count) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认删除吗？" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            __block NSError *err;
            
            MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self];
            __block NSInteger index = 0;
            [self.selectedIndexs enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, BOOL * _Nonnull stop) {
                [fileManager removeItemAtURL:obj.fileURL error:&err];
                if (err == nil) {
                    [obj.parentFile.subFiles removeObject:obj];
                    index++;
                    aHUD.label.text = [NSString stringWithFormat:@"%ld/%ld", index, self.selectedIndexs.count];
                }
                else {
                    [aHUD hideAnimated:YES];
                    [MBProgressHUD showWithError:err];
                    *stop = YES;
                }
            }];
            
            //没有错误
            if (index == self.selectedIndexs.count) {
                [aHUD hideAnimated:YES];
                [self.collectionView reloadData];
            }
        }]];
        
        [self.viewController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)touchCancelButton:(UIButton *)button {
    [self.selectedIndexs removeAllObjects];
    _isEditMode = NO;
    [self.collectionView reloadData];
    [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [self layoutIfNeeded];
//    }];
}

#pragma mark - 懒加载
- (BaseCollectionView *)collectionView {
    if (_collectionView == nil) {
        
        UICollectionViewLayout *layout = nil;
        if (_type == FileManagerViewTypeLong || _type == FileManagerViewTypePlayerList) {
            layout = self.longStyleFlowLayout;
        }
        else {
            layout = self.shortStyleFlowLayout;
        }
        
        _collectionView = [[BaseCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.emptyDataSetSource = self;
        @weakify(self)
        [_collectionView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithActionBlock:^(UILongPressGestureRecognizer * _Nonnull gesture) {
            @strongify(self)
            if (!self) return;
            
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                {
                    if (self.type != FileManagerViewTypePlayerList) {
                        self->_isEditMode = YES;
                        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(50);
                        }];
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            [self layoutIfNeeded];
                        }];
                    }
                }
                    break;
                default:
                    break;
            }
            
        }]];
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[FileManagerFileLongCollectionViewCell class] forCellWithReuseIdentifier:@"FileManagerFileLongCollectionViewCell"];
        [_collectionView registerClass:[FileManagerFolderLongCollectionViewCell class] forCellWithReuseIdentifier:@"FileManagerFolderLongCollectionViewCell"];
        [_collectionView registerClass:[FileManagerFolderShortCollectionViewCell class] forCellWithReuseIdentifier:@"FileManagerFolderShortCollectionViewCell"];
        [_collectionView registerClass:[FileManagerFolderPlayerListCollectionViewCell class] forCellWithReuseIdentifier:@"FileManagerFolderPlayerListCollectionViewCell"];

        _collectionView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererVideoWithFileModel:_currentFile completion:^(JHFile *file) {
                _currentFile = file;
                [self.collectionView reloadData];
                [self.collectionView endRefreshing];
            }];
        }];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)longStyleFlowLayout {
    if (_longStyleFlowLayout == nil) {
        _longStyleFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _longStyleFlowLayout.minimumLineSpacing = 0;
        _longStyleFlowLayout.minimumInteritemSpacing = 0;
    }
    return _longStyleFlowLayout;
}

- (UICollectionViewFlowLayout *)shortStyleFlowLayout {
    if (_shortStyleFlowLayout == nil) {
        _shortStyleFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _shortStyleFlowLayout.minimumLineSpacing = SHORT_TYPE_EDGE;
        _shortStyleFlowLayout.minimumInteritemSpacing = SHORT_TYPE_EDGE;
        _shortStyleFlowLayout.sectionInset = UIEdgeInsetsMake(0, SHORT_TYPE_EDGE, 0, SHORT_TYPE_EDGE);
    }
    return _shortStyleFlowLayout;
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
//        [_editView addSubview:self.moveButton];
        [_editView addSubview:self.deleteButton];
        [_editView addSubview:self.cancelButton];
        
        [self.selectedAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_offset(0);
            make.width.height.mas_equalTo(@[/*self.moveButton, */self.deleteButton, self.cancelButton]);
        }];
        
//        [self.moveButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.selectedAllButton.mas_right);
//            make.centerY.equalTo(self.selectedAllButton);
//        }];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectedAllButton.mas_right);
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
    }
    return _selectedAllButton;
}

//- (UIButton *)moveButton {
//    if (_moveButton == nil) {
//        _moveButton = [[UIButton alloc] init];
//        [_moveButton setTitle:@"移动至..." forState:UIControlStateNormal];
//        _moveButton.titleLabel.font = NORMAL_SIZE_FONT;
//        [_moveButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
//        [_moveButton addTarget:self action:@selector(touchMoveButton:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _moveButton;
//}

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
