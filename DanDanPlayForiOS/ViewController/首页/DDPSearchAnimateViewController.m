//
//  DDPSearchAnimateViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPSearchAnimateViewController.h"
#import "DDPBaseTableView.h"
#import "DDPNewSearchAnimateTableViewCell.h"
#import "DDPAttentionDetailViewController.h"
#import "DDPRefreshNormalHeader.h"

@interface DDPSearchAnimateViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) DDPSearchAnimeDetailsCollection *models;
@end

@implementation DDPSearchAnimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (self.keyword.length) {
        [self.tableView.mj_header beginRefreshing];        
    }
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    if (self.isViewLoaded) {
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark - 私有方法
- (void)requestWithKeyword {
    if (self.keyword.length == 0) {
        [self.tableView endRefreshing];
        return;
    }
    
    @weakify(self)
    [DDPSearchNetManagerOperation searchAnimateWithKeyword:self.keyword type:nil completionHandler:^(DDPSearchAnimeDetailsCollection *collection, NSError *error) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        [self.tableView endRefreshing];
        if (error == nil) {
            self.models = collection;
            [self.tableView reloadData];
        }
        else {
            [self.view showWithError:error];
        }
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPNewSearchAnimateTableViewCell *cell = [tableView dequeueReusableCellWithClass:[DDPNewSearchAnimateTableViewCell class] forIndexPath:indexPath];
    cell.model = self.models.collection[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    DDPSearchAnimeDetails *model = self.models.collection[indexPath.row];
    
    DDPAttentionDetailViewController *vc = [[DDPAttentionDetailViewController alloc] init];
    vc.animateId = model.identity;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showEmptyView = YES;
        _tableView.titleForEmptyView = @"没有搜索到结果";
        _tableView.descriptionForEmptyView = @"换个关键词试试吧╮(╯▽╰)╭";
        _tableView.rowHeight = 120;
        [_tableView registerCellFromXib:[DDPNewSearchAnimateTableViewCell class]];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.mj_header = [DDPRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestWithKeyword)];
    }
    return _tableView;
}

@end
