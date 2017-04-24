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

#import "BaseTableView.h"
#import "LocalFileTableViewCell.h"

@interface LocalFileViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation LocalFileViewController
{
    NSArray <VideoModel *>*_currentArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocalFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileTableViewCell" forIndexPath:indexPath];
    cell.model = _currentArr[indexPath.row];
    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _currentArr = [CacheManager shareCacheManager].videoModels;
        [self.view endEditing:YES];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[c] %@", searchText];
        _currentArr = [[CacheManager shareCacheManager].videoModels filteredArrayUsingPredicate:predicate];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
	if(_tableView == nil) {
		_tableView = [[BaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
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
