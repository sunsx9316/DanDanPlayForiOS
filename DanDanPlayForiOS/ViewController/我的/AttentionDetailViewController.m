//
//  AttentionDetailViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionDetailViewController.h"
#import "HomePageSearchViewController.h"

#import "JHBaseTableView.h"
#import "AttentionDetailTableViewCell.h"
#import "AttentionDetailHistoryTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSDate+Tools.h"
#import "JHEdgeButton.h"

@interface AttentionDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) JHPlayHistory *historyModel;
@end

@implementation AttentionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configRightItem];
    
    self.navigationItem.title = @"番剧详情";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return !!self.historyModel;
    }
    return self.historyModel.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AttentionDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttentionDetailTableViewCell" forIndexPath:indexPath];
        cell.model = self.historyModel;
        @weakify(self)
        cell.touchSearchButtonCallBack = ^(JHPlayHistory *aModel) {
            @strongify(self)
            if (!self) return;
            
            HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
            JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
            vc.config = config;
            config.keyword = self.historyModel.searchKeyword.length ? self.historyModel.searchKeyword : self.historyModel.name;
            [self.navigationController pushViewController:vc animated:YES];
        };
        return cell;
    }
    
    AttentionDetailHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttentionDetailHistoryTableViewCell" forIndexPath:indexPath];
    cell.model = self.historyModel.collection[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return DETAIL_CELL_HEIGHT + 40;
    }
    
    return [tableView fd_heightForCellWithIdentifier:@"AttentionDetailHistoryTableViewCell" cacheByIndexPath:indexPath configuration:^(AttentionDetailHistoryTableViewCell *cell) {
        cell.model = self.historyModel.collection[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        //未登录
        if ([CacheManager shareCacheManager].user == nil) {
            [[ToolsManager shareToolsManager] popLoginAlertViewInViewController:self];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            JHEpisode *model = self.historyModel.collection[indexPath.row];
            //已观看
            if (model.time.length != 0) return;
            
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"是否标记为已看过？" message:@"将会自动关注这个动画" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [MBProgressHUD showLoadingInView:self.view text:@"添加中..."];
                [FavoriteNetManager favoriteAddHistoryWithUser:[CacheManager shareCacheManager].user episodeId:model.identity addToFavorite:YES completionHandler:^(NSError *error) {
                    [MBProgressHUD hideLoading];
                    
                    if (error) {
                        [MBProgressHUD showWithError:error];
                    }
                    else {
                        model.time = [NSDate historyTimeStyleWithDate:[NSDate date]];
                        if (self.attentionCallBack) {
                            self.attentionCallBack(self.animateId);
                        }
                        [self.tableView reloadData];
                    }
                }];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if (offset > DETAIL_CELL_HEIGHT + 40) {
        self.navigationItem.title = self.historyModel.name;
    }
    else {
        self.navigationItem.title = @"番剧详情";
    }
}

#pragma mark - 私有方法
//- (void)configRightItem {
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_search"] configAction:^(UIButton *aButton) {
//        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
//    }];
//
//    [self.navigationItem addRightItemFixedSpace:item];
//}

//- (void)touchRightItem:(UIButton *)button {
//    if (self.historyModel.name.length == 0) return;
//
//    HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
//    JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
//    vc.config = config;
//    config.keyword = self.historyModel.name;
//    [self.navigationController pushViewController:vc animated:YES];
//}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[AttentionDetailTableViewCell class] forCellReuseIdentifier:@"AttentionDetailTableViewCell"];
        [_tableView registerClass:[AttentionDetailHistoryTableViewCell class] forCellReuseIdentifier:@"AttentionDetailHistoryTableViewCell"];
        
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [FavoriteNetManager favoriteHistoryAnimateWithUser:[CacheManager shareCacheManager].user animateId:self.animateId completionHandler:^(JHPlayHistory *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    self.historyModel = responseObject;
                    self.historyModel.isOnAir = self.isOnAir;
                    [self.tableView reloadData];
                }
                
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
