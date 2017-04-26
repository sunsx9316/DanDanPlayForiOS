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

#import "BaseTableView.h"
#import "LocalFileTableViewCell.h"
#import "JHEdgeButton.h"

@interface LocalFileViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation LocalFileViewController
{
    NSMutableArray <VideoModel *>*_currentArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件";
    
    [self configRightItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
    
    _currentArr = [CacheManager shareCacheManager].videoModels;
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
    
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VideoModel *model = _currentArr[indexPath.row];
    
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
            [aHUD hideAnimated:YES];
            
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocalFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileTableViewCell" forIndexPath:indexPath];
    cell.model = _currentArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoModel *model = _currentArr[indexPath.row];
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:@"操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [_currentArr removeObject:model];
        [[NSFileManager defaultManager] removeItemAtURL:model.fileURL error:nil];
        if (_currentArr != [CacheManager shareCacheManager].videoModels) {
            [[CacheManager shareCacheManager].videoModels removeObject:model];
        }

        [self.tableView reloadData];
    }]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"( ´_ゝ`)没有视频 点击刷新" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"通过iTunes、其它软件或者点击右上角的\"+\"号导入" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _currentArr = [CacheManager shareCacheManager].videoModels;
        [self.view endEditing:YES];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[c] %@", searchText];
        _currentArr = [[CacheManager shareCacheManager].videoModels filteredArrayUsingPredicate:predicate].mutableCopy;
    }
    
    [self.tableView reloadData];
}

#pragma mark - 私有方法
- (void)reload {
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
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
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
	if(_tableView == nil) {
		_tableView = [[BaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.emptyDataSetSource = self;
        
        [_tableView registerClass:[LocalFileTableViewCell class] forCellReuseIdentifier:@"LocalFileTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [[ToolsManager shareToolsManager] startDiscovererVideoWithPath:nil completion:^(NSArray<VideoModel *> *videos) {
                
                [self.tableView reloadData];
                [self.tableView endRefreshing];
            }];
            
        }];
        [self.view addSubview:_tableView];
	}
	return _tableView;
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _searchBar.placeholder = @"搜索文件名";
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

@end
