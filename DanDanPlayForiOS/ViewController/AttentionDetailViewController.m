//
//  AttentionDetailViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionDetailViewController.h"
#import "BaseTableView.h"
#import "AttentionDetailTableViewCell.h"
#import "AttentionDetailHistoryTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSDate+Tools.h"

@interface AttentionDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) JHPlayHistory *historyModel;
@end

@implementation AttentionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.model.name;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefresh {
    [self.tableView endRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.historyModel.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AttentionDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttentionDetailTableViewCell" forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }
    
    AttentionDetailHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttentionDetailHistoryTableViewCell" forIndexPath:indexPath];
    cell.model = self.historyModel.collection[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    JHEpisode *model = self.historyModel.collection[indexPath.row];
    [MBProgressHUD showLoadingInView:self.view text:@"添加中..."];
    [FavoriteNetManager favoriteAddHistoryWithUser:[CacheManager shareCacheManager].user episodeId:model.identity addToFavorite:YES completionHandler:^(NSError *error) {
        [MBProgressHUD hideLoading];
        
        if (error) {
            [MBProgressHUD showWithError:error];
        }
        else {
            model.time = [NSDate historyTimeStyleWithDate:[NSDate date]];
            self.model.episodeWatched++;
            if (self.attentionCallBack) {
                self.attentionCallBack(self.model);
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 140;
    }
    
    return [tableView fd_heightForCellWithIdentifier:@"AttentionDetailHistoryTableViewCell" cacheByIndexPath:indexPath configuration:^(AttentionDetailHistoryTableViewCell *cell) {
        cell.model = self.historyModel.collection[indexPath.row];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        JHEpisode *model = self.historyModel.collection[indexPath.row];
        return model.time.length == 0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"已阅";
}


#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[AttentionDetailTableViewCell class] forCellReuseIdentifier:@"AttentionDetailTableViewCell"];
        [_tableView registerClass:[AttentionDetailHistoryTableViewCell class] forCellReuseIdentifier:@"AttentionDetailHistoryTableViewCell"];
        
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [FavoriteNetManager favoriteHistoryAnimateWithUser:[CacheManager shareCacheManager].user animateId:self.model.identity completionHandler:^(JHPlayHistory *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    self.historyModel = responseObject;
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
