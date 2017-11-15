//
//  FileManagerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerViewController.h"
#import "SMBFileViewController.h"
#import "MatchViewController.h"
#import "PlayNavigationController.h"
#import "HTTPServerViewController.h"
#import "JHEdgeButton.h"

#import "FileManagerFileLongViewCell.h"
#import "FileManagerFolderLongViewCell.h"
#import "FileManagerEditView.h"
#import "FileManagerSearchView.h"

#import "SMBVideoModel.h"
#import "JHCollectionCache.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NSURL+Tools.h"
#import "NSString+Tools.h"

@interface FileManagerViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, MGSwipeTableCellDelegate, CacheManagerDelagate, FileManagerSearchViewDelegate>

@property (strong, nonatomic) FileManagerEditView *editView;
@property (strong, nonatomic) FileManagerSearchView *searchView;
@end

@implementation FileManagerViewController
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: MAIN_COLOR, NSFontAttributeName : NORMAL_SIZE_FONT};
//    
//    if (jh_isRootFile(self.file)) {
//        [self setNavigationBarWithColor:[UIColor clearColor]];
//        [[CacheManager shareCacheManager] addObserver:self];
//    }
//    else {
//        [self setNavigationBarWithColor:[UIColor whiteColor]];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configRightItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileSuccess:) name:DELETE_FILE_SUCCESS_NOTICE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveFileSuccess:) name:MOVE_FILE_SUCCESS_NOTICE object:nil];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
    }];
    
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.top.equalTo(self.tableView.mas_bottom);
    }];
    
    [self.tableView addGestureRecognizer:self.longPressGestureRecognizer];
    
    if (jh_isRootFile(self.file)) {
//        self.automaticallyAdjustsScrollViewInsets = NO;
        
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
        
        self.navigationItem.title = @"根目录";
        [[CacheManager shareCacheManager] addObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:WRITE_FILE_SUCCESS_NOTICE object:nil];
    }
    else {
//        self.automaticallyAdjustsScrollViewInsets = YES;
        self.navigationItem.title = _file.name;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CacheManager shareCacheManager] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == JHFileTypeDocument) {
        FileManagerFileLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFileLongViewCell" forIndexPath:indexPath];
        cell.model = file.videoModel;
        
        NSMutableArray *buttons = [NSMutableArray array];
        [buttons addObject:({
            MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:RGBCOLOR(255, 48, 54)];
            button.buttonWidth = 80;
            button;
        })];
        
        cell.rightButtons = buttons;
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        cell.delegate = self;
        return cell;
    }
    
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.fileURL.lastPathComponent;
    
    cell.detailLabel.text = [NSString stringWithFormat:@"%@个视频", [NSString numberFormatterWithUpper:0 number:file.subFiles.count]];
    cell.iconImgView.image = [UIImage imageNamed:@"comment_local_file_folder"];
    
    NSMutableArray *buttons = [NSMutableArray array];
    [buttons addObject:({
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:RGBCOLOR(255, 48, 54)];
        button.buttonWidth = 80;
        button;
    })];
    
    [buttons addObject:({
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"收藏" backgroundColor:RGBCOLOR(88, 85, 209)];
        button.buttonWidth = 90;
        button;
    })];
    
    cell.rightButtons = buttons;
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = _file.subFiles[indexPath.row];
    if (file.type == JHFileTypeFolder) {
//        return 80 + 40 * jh_isPad();
        return UITableViewAutomaticDimension;
    }
    return 100 + 40 * jh_isPad();
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self matchFile:self.file.subFiles[indexPath.row]];
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

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //删除
    if (index == 0) {
        if (indexPath) {
            JHFile *file = self.file.subFiles[indexPath.row];
            if (file.type == JHFileTypeFolder) {
                [self deleteFiles:file.subFiles];
            }
            else {
                [self deleteFiles:@[file]];
            }
        }
    }
    //收藏
    else {
        JHFile *file = self.file.subFiles[indexPath.row];
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"是否添加此文件夹到收藏" message:file.videoModel.fileNameWithPathExtension preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            JHCollectionCache *cache = [[JHCollectionCache alloc] init];

            NSString *relativePath = [file.fileURL relativePathWithBaseURL:[UIApplication sharedApplication].documentsURL];
            if (relativePath.length) {
                cache.fileURL = [NSURL URLWithString:relativePath];
                cache.name = file.videoModel.fileNameWithPathExtension;
                cache.cacheType = JHCollectionCacheTypeLocal;
                NSError *error = [[CacheManager shareCacheManager] addCollectionCache:cache];
                if (error) {
                    [MBProgressHUD showWithText:[NSString stringWithFormat:@"添加失败！ %@", error.localizedDescription]];
                }
                else {
                    [MBProgressHUD showWithText:@"添加成功！"];
                }
            }
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    return YES;
}

#pragma mark - CacheManagerDelagate
- (void)SMBDownloadTasksDidChange:(NSArray <TOSMBSessionDownloadTask *>*)tasks type:(SMBDownloadTasksDidChangeType)type {
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

- (void)lastPlayTimeWithVideoModel:(VideoModel *)videoModel time:(NSInteger)time {
    [self.tableView reloadData];
}

#pragma mark - FileManagerSearchViewDelegate
- (void)searchView:(FileManagerSearchView *)searchView didSelectedFile:(JHFile *)file {
    [self matchFile:file];
}

#pragma mark - 私有方法
//- (void)configLeftItem {
//    if (jh_isRootFile(self.file) == NO) {
//        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"comment_back_item"] yy_imageByTintColor:MAIN_COLOR] configAction:^(UIButton *aButton) {
//             [aButton addTarget:self action:@selector(touchLeftItem:) forControlEvents:UIControlEventTouchUpInside];
//        }];
//
//        [self.navigationItem addLeftItemFixedSpace:item];
//    }
//}

- (void)touchSelectedAllButton:(UIButton *)button {
    button.selected = !button.isSelected;
    
    if (button.isSelected) {
        [self.file.subFiles enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)touchMoveButton:(UIButton *)button {
    NSArray <JHFile *>*moveFiles = [self selectedFiles];
    
    if (moveFiles.count) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"移动到文件夹" message:nil preferredStyle:UIAlertControllerStyleAlert];
        @weakify(vc);
        [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"文件夹名称 为空则移动至根目录";
        }];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(vc)
            if (!vc) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UITextField *textField = vc.textFields.firstObject;
                
                if ([textField.text containsString:@"/"]) {
                    [MBProgressHUD showWithText:@"文件夹名称不合法！"];
                    return;
                }
                
                [moveFiles enumerateObjectsUsingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj removeFromParentFile];
                }];
                
                [[ToolsManager shareToolsManager] moveFiles:moveFiles toFolder:textField.text];
                [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_FILE_SUCCESS_NOTICE object:nil];
                //            [self.tableView reloadData];
                [self touchCancelButton:nil];
                
                NSArray *VCArr = self.navigationController.viewControllers;
                __block UIViewController *toVC = nil;
                [VCArr enumerateObjectsUsingBlock:^(FileManagerViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[FileManagerViewController class]] && jh_isRootFile(obj.file)) {
                        toVC = obj;
                        *stop = YES;
                    }
                }];
                
                if (toVC) {
                    [self.navigationController popToViewController:toVC animated:YES];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                //            [self refresh];
            });
        }]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)touchDeleteButton:(UIButton *)button {
    [self deleteFiles:[self selectedFiles]];
}

- (void)touchCancelButton:(UIButton *)button {
    if (self.tableView.isEditing == YES) {
        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    [self.tableView setEditing:NO];
}

- (void)deleteFiles:(NSArray <JHFile *>*)files {
    
    if (files.count == 0) return;
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认删除吗？" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [files enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //文件夹则删除它的子文件 同时将自己从父目录中移除
            if (obj.type == JHFileTypeFolder) {
                [obj.subFiles enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHFile * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                    [fileManager removeItemAtURL:obj1.fileURL error:nil];
                    [obj1 removeFromParentFile];
                }];
                
                [obj removeFromParentFile];
            }
            //文件则将它从父目录中移除 如果父目录为空 则将父目录从父目录的父目录移除
            else {
                [fileManager removeItemAtURL:obj.fileURL error:nil];
                [obj removeFromParentFile];
                
                //文件夹为空
                if (obj.parentFile.subFiles.count == 0) {
                    [obj.parentFile removeFromParentFile];
                }
            }
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_FILE_SUCCESS_NOTICE object:nil];
        [self touchCancelButton:nil];
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSArray <JHFile *>*)selectedFiles {
    NSArray <NSIndexPath *>*indexs = self.tableView.indexPathsForSelectedRows;
    NSMutableArray <JHFile *>*moveFiles = [NSMutableArray array];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [moveFiles addObject:self.file.subFiles[obj.row]];
    }];
    return moveFiles;
}

- (void)deleteFileSuccess:(NSNotification *)aSender {
    if (jh_isRootFile(self.file)) {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
    else {
        [self.tableView reloadData];
        [self.tableView endRefreshing];
    }
}

- (void)moveFileSuccess:(NSNotification *)aSender {
    if (jh_isRootFile(self.file)) {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
}

- (void)matchFile:(JHFile *)file {
    if (file.type == JHFileTypeDocument) {
        VideoModel *model = file.videoModel;
        void(^jumpToMatchVCAction)(void) = ^{
            MatchViewController *vc = [[MatchViewController alloc] init];
            vc.model = model;
            vc.hidesBottomBarWhenPushed = YES;
            [self.parentViewController.navigationController pushViewController:vc animated:YES];
        };
        
        if ([CacheManager shareCacheManager].openFastMatch) {
            MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
            [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
                aHUD.progress = progress;
                aHUD.label.text = jh_danmakusProgressToString(progress);
            } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
                model.danmakus = responseObject;
                [aHUD hideAnimated:NO];
                
                if (responseObject == nil) {
                    jumpToMatchVCAction();
                }
                else {
                    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:model];
                    [self presentViewController:nav animated:YES completion:nil];
                }
            }];
        }
        else {
            jumpToMatchVCAction();
        }
        
    }
    else if (file.type == JHFileTypeFolder) {
        FileManagerViewController *vc = [[FileManagerViewController alloc] init];
        vc.file = file;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)refresh:(NSNotification *)aSender {
    
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_search"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_add_file"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchHttpButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemsFixedSpace:@[addItem, item]];
}

- (void)touchSearchButton:(UIButton *)sender {
    self.searchView.file = self.file;
    [self.searchView show];
}

- (void)touchHttpButton:(UIButton *)button {
    HTTPServerViewController *vc = [[HTTPServerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.estimatedRowHeight = 80;
        _tableView.allowsMultipleSelection = YES;
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:[FileManagerFileLongViewCell class] forCellReuseIdentifier:@"FileManagerFileLongViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererVideoWithFile:self.file type:PickerFileTypeVideo completion:^(JHFile *file) {
                self.file = file;
                [self.tableView reloadData];
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
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
                    if (self.tableView.isEditing == NO) {
                        [self.tableView setEditing:YES animated:YES];
                        
                        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
                        if (indexPath) {
                            //将当前长按的cell加入选择
                            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                        }
                        
                        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(50);
                        }];
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            [self.view layoutIfNeeded];
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

- (FileManagerEditView *)editView {
    if (_editView == nil) {
        _editView = [[FileManagerEditView alloc] init];
        [_editView.selectedAllButton addTarget:self action:@selector(touchSelectedAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [_editView.moveButton addTarget:self action:@selector(touchMoveButton:) forControlEvents:UIControlEventTouchUpInside];
        [_editView.deleteButton addTarget:self action:@selector(touchDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [_editView.cancelButton addTarget:self action:@selector(touchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_editView];
    }
    return _editView;
}

- (FileManagerSearchView *)searchView {
    if (_searchView == nil) {
        _searchView = [[FileManagerSearchView alloc] init];
        _searchView.delegete = self;
    }
    return _searchView;
}

@end
