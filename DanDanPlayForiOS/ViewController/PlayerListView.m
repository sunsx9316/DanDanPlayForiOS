//
//  PlayerListView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerListView.h"
#import "BaseTableView.h"
#import "PlayerListTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface PlayerListView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation PlayerListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CacheManager shareCacheManager].videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerListTableViewCell" forIndexPath:indexPath];
    cell.model = [CacheManager shareCacheManager].videoModels[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedModelCallBack) {
        self.didSelectedModelCallBack([CacheManager shareCacheManager].videoModels[indexPath.row]);
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"PlayerListTableViewCell" cacheByIndexPath:indexPath configuration:^(PlayerListTableViewCell *cell) {
        cell.model = [CacheManager shareCacheManager].videoModels[indexPath.row];
    }];
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[PlayerListTableViewCell class] forCellReuseIdentifier:@"PlayerListTableViewCell"];
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
