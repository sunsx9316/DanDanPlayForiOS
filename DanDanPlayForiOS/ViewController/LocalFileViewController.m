//
//  LocalFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LocalFileViewController.h"
#import "BaseTableView.h"
#import "LocalFileTableViewCell.h"

@interface LocalFileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation LocalFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ToolsManager shareToolsManager].videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocalFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileTableViewCell" forIndexPath:indexPath];
    cell.model = [ToolsManager shareToolsManager].videoModels[indexPath.row];
    return cell;
}


#pragma mark - 懒加载
- (BaseTableView *)tableView {
	if(_tableView == nil) {
		_tableView = [[BaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[LocalFileTableViewCell class] forCellReuseIdentifier:@"LocalFileTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            
        }];
        [self.view addSubview:_tableView];
	}
	return _tableView;
}

@end
