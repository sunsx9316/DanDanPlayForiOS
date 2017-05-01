//
//  LocalFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LocalFileViewController.h"
#import "MatchViewController.h"
#import "PlayNavigationController.h"
#import "FTPViewController.h"

//#import "BaseTreeView.h"
//#import "LocalFileTableViewCell.h"
//#import "LocalFolderTableViewCell.h"
#import "JHEdgeButton.h"
#import "FileManagerView.h"

@interface LocalFileViewController ()<UISearchBarDelegate, FileManagerViewDelegate>
//@property (strong, nonatomic) BaseTreeView *treeView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) FileManagerView *fileManagerView;
@end

@implementation LocalFileViewController
{
//    NSMutableArray <VideoModel *>*_currentArr;
    JHFile *_currentFile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件";
    
    [self configRightItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
    
//    _currentArr = [CacheManager shareCacheManager].videoModels;
    _currentFile = [CacheManager shareCacheManager].rootFile;
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(SEARCH_BAR_HEIRHT);
    }];
    
    [self.fileManagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
    
//    if (self.treeView.jh_tableView.mj_header.refreshingBlock) {
//        self.treeView.jh_tableView.mj_header.refreshingBlock();
//    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
//    [self.fileManagerView.collectionView.collectionViewLayout invalidateLayout];
//}

//#pragma mark - RATreeViewDelegate
//- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(JHFile *)item {
//    if (item.type == JHFileTypeFolder) {
//        return 44 + 20 * jh_isPad();
//    }
//    
//    return 100 + 80 * jh_isPad();
//}

//- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(JHFile *)item {
//    if (item.type == JHFileTypeFolder) {
//        LocalFolderTableViewCell *cell = (LocalFolderTableViewCell *)[treeView cellForItem:item];
//        [cell expandArrow:YES animate:YES];
//    }
//}
//
//- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(JHFile *)item {
//    if (item.type == JHFileTypeFolder) {
//        MatchTitleTableViewCell *cell = (MatchTitleTableViewCell *)[treeView cellForItem:item];
//        [cell expandArrow:NO animate:YES];
//    }
//}

//- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(JHFile *)item {
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (NSString *)treeView:(RATreeView *)treeView titleForDeleteConfirmationButtonForRowForItem:(id)item {
//    return @"删除";
//}
//
//- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(JHFile *)item {
////    [treeView deselectRowForItem:item animated:YES];
//    
//    if (item.type == JHFileTypeFolder) {
//        if (item.isParse == NO) {
//            [[ToolsManager shareToolsManager] startDiscovererVideoWithFileModel:item completion:^(JHFile *file) {
//                [self.treeView reloadData];
//                [self.treeView expandRowForItem:file withRowAnimation:RATreeViewRowAnimationAutomatic];
//            }];
//        }
//    }
//    else {
//        VideoModel *model = item.videoModel;
//        
//        void(^jumpToMatchVCAction)() = ^{
//            MatchViewController *vc = [[MatchViewController alloc] init];
//            vc.model = model;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        };
//        
//        if ([CacheManager shareCacheManager].openFastMatch) {
//            MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
//            [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
//                aHUD.progress = progress;
//                aHUD.label.text = danmakusProgressToString(progress);
//            } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
//                model.danmakus = responseObject;
//                [aHUD hideAnimated:YES];
//                
//                if (responseObject == nil) {
//                    jumpToMatchVCAction();
//                }
//                else {
//                    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:model];
//                    [self presentViewController:nav animated:YES completion:nil];
//                }
//            }];
//        }
//        else {
//            jumpToMatchVCAction();
//        }
//    }
//}
//
//#pragma mark - RATreeViewDataSource
//- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(JHFile *)item {
//    if (item == nil) {
//        return _currentFile.subFiles.count;
//    }
//    
//    return item.subFiles.count;
//}
//
//- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(JHFile *)item {
//    if (item.type == JHFileTypeFolder) {
//        LocalFolderTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"LocalFolderTableViewCell"];
//        cell.titleLabel.text = item.fileURL.lastPathComponent;
//        return cell;
//    }
//    
//    LocalFileTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"LocalFileTableViewCell"];
//    cell.model = item.videoModel;
//    return cell;
//}
//
//- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(JHFile *)item {
//    if (item == nil) {
//        return _currentFile.subFiles[index];
//    }
//    return item.subFiles[index];
//}
//
//- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(JHFile *)item {
//    
//    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:@"操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
//    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        NSURL *aURL = item.fileURL;
//        [item.parentFile.subFiles removeObject:item];
////        [_currentArr removeObject:item.fileURL];
//        [[NSFileManager defaultManager] removeItemAtURL:aURL error:nil];
//        if (_currentFile != [CacheManager shareCacheManager].rootFile) {
////            [[CacheManager shareCacheManager].videoModels removeObject:model];
//            if (self.treeView.jh_tableView.mj_header.refreshingBlock) {
//                self.treeView.jh_tableView.mj_header.refreshingBlock();
//            }
//        }
//        
//        [self.treeView reloadData];
//    }]];
//    [self presentViewController:vc animated:YES completion:nil];
//}

//#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    VideoModel *model = _currentArr[indexPath.row];
//    
//    void(^jumpToMatchVCAction)() = ^{
//        MatchViewController *vc = [[MatchViewController alloc] init];
//        vc.model = model;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//    
//    if ([CacheManager shareCacheManager].openFastMatch) {
//        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
//        [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
//            aHUD.progress = progress;
//            aHUD.label.text = danmakusProgressToString(progress);
//        } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
//            model.danmakus = responseObject;
//            [aHUD hideAnimated:YES];
//            
//            if (responseObject == nil) {
//                jumpToMatchVCAction();
//            }
//            else {
//                PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:model];
//                [self presentViewController:nav animated:YES completion:nil];
//            }
//        }];
//    }
//    else {
//        jumpToMatchVCAction();
//    }
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除";
//}
//
//#pragma mark - UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _currentArr.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    LocalFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileTableViewCell" forIndexPath:indexPath];
//    cell.model = _currentArr[indexPath.row];
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    VideoModel *model = _currentArr[indexPath.row];
//    
//    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:@"操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
//    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [_currentArr removeObject:model];
//        [[NSFileManager defaultManager] removeItemAtURL:model.fileURL error:nil];
//        if (_currentArr != [CacheManager shareCacheManager].videoModels) {
//            [[CacheManager shareCacheManager].videoModels removeObject:model];
//        }
//
//        [self.treeView reloadData];
//    }]];
//    [self presentViewController:vc animated:YES completion:nil];
//}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.fileManagerView.searchKey = nil;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    if (searchText.length) {
        self.fileManagerView.searchKey = searchText;
//        _currentFile = [CacheManager shareCacheManager].rootFile;
//        [self.view endEditing:YES];
//        [self.treeView reloadData];
    }
//    else {
////        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[c] %@", searchText];
////        _currentArr = [[CacheManager shareCacheManager].videoModels filteredArrayUsingPredicate:predicate].mutableCopy;
//        [[ToolsManager shareToolsManager] startSearchVideoWithFileModel:nil searchKey:searchText completion:^(JHFile *file) {
//            _currentFile = file;
//            [self.treeView reloadData];
//        }];
//    }

    
}

#pragma mark - FileManagerViewDelegate
- (void)managerView:(FileManagerView *)managerView didselectedModel:(JHFile *)file {
    VideoModel *model = file.videoModel;

    void(^jumpToMatchVCAction)() = ^{
        MatchViewController *vc = [[MatchViewController alloc] init];
        vc.model = model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };

    if ([CacheManager shareCacheManager].openFastMatch) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = danmakusProgressToString(progress);
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

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if (searchText.length == 0) {
//        _currentArr = [CacheManager shareCacheManager].videoModels;
//        [self.view endEditing:YES];
//    }
//    else {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[c] %@", searchText];
//        _currentArr = [[CacheManager shareCacheManager].videoModels filteredArrayUsingPredicate:predicate].mutableCopy;
//    }
//    
//    [self.treeView reloadData];
//}

#pragma mark - 私有方法
- (void)reload {
//    if (self.treeView.jh_tableView.mj_header.refreshingBlock) {
//        self.treeView.jh_tableView.mj_header.refreshingBlock();
//    }
}

- (void)configLeftItem {
    
}

- (void)configRightItem {
    JHEdgeButton *backButton = [[JHEdgeButton alloc] init];
    backButton.inset = CGSizeMake(10, 10);
    [backButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"add_file"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)touchRightItem:(UIButton *)button {
    FTPViewController *vc = [[FTPViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
//    self.fileManagerView.type = !self.fileManagerView.type;
}

#pragma mark - 懒加载

//- (BaseTreeView *)treeView {
//    if (_treeView == nil) {
//        _treeView = [[BaseTreeView alloc] initWithFrame:CGRectZero style:RATreeViewStylePlain];
//        _treeView.delegate = self;
//        _treeView.dataSource = self;
//        _treeView.rowsExpandingAnimation = RATreeViewRowAnimationTop;
//        _treeView.rowsCollapsingAnimation = RATreeViewRowAnimationTop;
//        
//        _treeView.jh_tableView.emptyDataSetSource = self;
//        
//        [_treeView registerClass:[LocalFileTableViewCell class] forCellReuseIdentifier:@"LocalFileTableViewCell"];
//        [_treeView registerClass:[LocalFolderTableViewCell class] forCellReuseIdentifier:@"LocalFolderTableViewCell"];
//        _treeView.treeFooterView = [[UIView alloc] init];
//        
//        @weakify(self)
//        _treeView.jh_tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
//            @strongify(self)
//            if (!self) return;
//            
//            [[ToolsManager shareToolsManager] startDiscovererVideoWithFileModel:nil completion:^(JHFile *file) {
//                [self.treeView reloadData];
//                [self.treeView endRefreshing];
//            }];
//        }];
//        
//        [self.view addSubview:_treeView];
//    }
//    return _treeView;
//}

//- (BaseTableView *)tableView {
//	if(_tableView == nil) {
//		_tableView = [[BaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        _tableView.rowHeight = 100 + 80 * jh_isPad();
//        _tableView.emptyDataSetSource = self;
//        
//        [_tableView registerClass:[LocalFileTableViewCell class] forCellReuseIdentifier:@"LocalFileTableViewCell"];
//        _tableView.tableFooterView = [[UIView alloc] init];
//        @weakify(self)
//        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
//            @strongify(self)
//            if (!self) return;
//            
//            [[ToolsManager shareToolsManager] startDiscovererVideoWithPath:nil completion:^(NSArray<VideoModel *> *videos) {
//                
//                [self.tableView reloadData];
//                [self.tableView endRefreshing];
//            }];
//            
//        }];
//        [self.view addSubview:_tableView];
//	}
//	return _tableView;
//}


- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
        _searchBar.placeholder = @"搜索文件名";
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

- (FileManagerView *)fileManagerView {
    if (_fileManagerView == nil) {
        _fileManagerView = [[FileManagerView alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.width, self.view.height - self.searchBar.bottom)];
        _fileManagerView.delegate = self;
        if (jh_isPad()) {
            _fileManagerView.type = FileManagerViewTypeShort;
        }
        [self.view addSubview:_fileManagerView];
    }
    return _fileManagerView;
}

@end
