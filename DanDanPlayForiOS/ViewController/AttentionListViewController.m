//
//  AttentionListViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionListViewController.h"
#import "AttentionDetailViewController.h"

#import "BaseTableView.h"
#import "AttentionListTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface AttentionListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) JHFavoriteCollection *model;
@end

@implementation AttentionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的关注";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefresh {
    [self.tableView endRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttentionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttentionListTableViewCell" forIndexPath:indexPath];
    cell.model = self.model.collection[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;
    JHFavorite *model = self.model.collection[index];
    
    [MBProgressHUD showLoadingInView:self.view text:nil];
    [FavoriteNetManager favoriteLikeWithUser:[CacheManager shareCacheManager].user animeId:model.identity like:NO completionHandler:^(NSError *error) {
        [MBProgressHUD hideLoading];
        
        if (error) {
            [MBProgressHUD showWithError:error atView:self.view];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATTENTION_SUCCESS_NOTICE object:@(model.identity) userInfo:@{ATTENTION_KEY : @(NO)}];
            
            [self.model.collection removeObjectAtIndex:index];
            [tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadEmptyDataSet];
        }
    }];
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JHFavorite *model = self.model.collection[indexPath.row];
    AttentionDetailViewController *vc = [[AttentionDetailViewController alloc] init];
    vc.animateId = model.identity;
    vc.isOnAir = model.isOnAir;
    @weakify(self)
    vc.attentionCallBack = ^(NSUInteger animateId) {
        @strongify(self)
        if (!self) return;
        model.episodeWatched++;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"AttentionListTableViewCell" cacheByIndexPath:indexPath configuration:^(AttentionListTableViewCell *cell) {
        cell.model = self.model.collection[indexPath.row];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消关注";
}


#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        [_tableView registerClass:[AttentionListTableViewCell class] forCellReuseIdentifier:@"AttentionListTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [FavoriteNetManager favoriteAnimateWithUser:[CacheManager shareCacheManager].user completionHandler:^(JHFavoriteCollection *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    self.model = responseObject;
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
