//
//  DDPBiliBiliSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliSearchViewController.h"
#import "DDPSearchNetManagerOperation.h"
#import "DDPBaseTableView.h"
#import "DDPBiliBiliSearchBangumiTableViewCell.h"
#import "DDPBiliBiliSearchVideoTableViewCell.h"

@interface DDPBiliBiliSearchViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) DDPBiliBiliSearchResult *searchResult;
@end

@implementation DDPBiliBiliSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        return self.searchResult.bangumi.count;
    }
    
    return self.searchResult.video.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DDPBiliBiliSearchBangumiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DDPBiliBiliSearchBangumiTableViewCell.className forIndexPath:indexPath];
        cell.model = self.searchResult.bangumi[indexPath.row];
        return cell;
    }
    
    DDPBiliBiliSearchVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DDPBiliBiliSearchVideoTableViewCell.className forIndexPath:indexPath];
    cell.model = self.searchResult.video[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 160;
    }
    return 100;
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[DDPBiliBiliSearchBangumiTableViewCell loadNib] forCellReuseIdentifier:DDPBiliBiliSearchBangumiTableViewCell.className];
        [_tableView registerNib:[DDPBiliBiliSearchVideoTableViewCell loadNib] forCellReuseIdentifier:DDPBiliBiliSearchVideoTableViewCell.className];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [DDPSearchNetManagerOperation searchBiliBiliWithkeyword:self.keyword completionHandler:^(DDPBiliBiliSearchResult *model, NSError *error) {
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    self.searchResult = model;
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
