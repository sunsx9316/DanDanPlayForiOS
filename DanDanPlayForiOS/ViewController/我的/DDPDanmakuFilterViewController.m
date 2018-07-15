//
//  DDPDanmakuFilterViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/30.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDanmakuFilterViewController.h"
#import "DDPDanmakuFilterDetailViewController.h"

#import "DDPBaseTableView.h"
#import "DDPDanmakuFilterTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "DDPEdgeButton.h"
#import "DDPCacheManager+multiply.h"

@interface DDPDanmakuFilterViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@end

@implementation DDPDanmakuFilterViewController
{
    BOOL _isUpdateFilter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"弹幕屏蔽列表";
    
    [self configRightItem];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    NSArray <DDPFilter *>*filters = [[DDPCacheManager shareCacheManager] danmakuFilters];
    if (filters.count == 0) {
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
}

- (void)dealloc {
    if (_isUpdateFilter && self.updateFilterCallBack) {
        self.updateFilterCallBack();
    }
}

#pragma mark - 私有方法
- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_add_file"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)aButton {
    DDPDanmakuFilterDetailViewController *vc = [[DDPDanmakuFilterDetailViewController alloc] init];
    @weakify(self)
    vc.addFilterCallback = ^(DDPFilter *model) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:model];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DDPCacheManager shareCacheManager].danmakuFilters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPDanmakuFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPDanmakuFilterTableViewCell" forIndexPath:indexPath];
    cell.model = [DDPCacheManager shareCacheManager].danmakuFilters[indexPath.row];
    @weakify(self)
    cell.touchEnableButtonCallBack = ^(DDPFilter *aModel) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:aModel];
    };
    
    cell.touchRegexButtonCallBack = ^(DDPFilter *aModel) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:aModel];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->_isUpdateFilter = YES;
        DDPFilter *model = [DDPCacheManager shareCacheManager].danmakuFilters[indexPath.row];
        [[DDPCacheManager shareCacheManager] removeFilter:model];
        [self.tableView reloadData];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"DDPDanmakuFilterTableViewCell" cacheByIndexPath:indexPath configuration:^(DDPDanmakuFilterTableViewCell *cell) {
        cell.model = [DDPCacheManager shareCacheManager].danmakuFilters[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DDPDanmakuFilterDetailViewController *vc = [[DDPDanmakuFilterDetailViewController alloc] init];
    vc.model = [DDPCacheManager shareCacheManager].danmakuFilters[indexPath.row];
    @weakify(self)
    vc.addFilterCallback = ^(DDPFilter *model) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:model];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[DDPDanmakuFilterTableViewCell class] forCellReuseIdentifier:@"DDPDanmakuFilterTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [DDPFilterNetManagerOperation cloudFilterListWithCompletionHandler:^(DDPFilterCollection *responseObject, NSError *error) {
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    
                    NSArray <DDPFilter *>*filters = [[DDPCacheManager shareCacheManager] danmakuFilters];
                    if (filters.count == 0) {
                        [[DDPCacheManager shareCacheManager] addFilters:responseObject.collection];
                    }
                    else {
                        NSMutableArray *addArr = [NSMutableArray arrayWithCapacity:filters.count];
                        
                        [responseObject.collection enumerateObjectsUsingBlock:^(DDPFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([filters containsObject:obj] == false) {
                                [addArr addObject:obj];
                            }
                        }];
                        
                        //保存云端新增列表
                        [[DDPCacheManager shareCacheManager] addFilters:addArr];
                    }
                    
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
