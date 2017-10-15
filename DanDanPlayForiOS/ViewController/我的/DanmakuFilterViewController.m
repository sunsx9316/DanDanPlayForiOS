//
//  DanmakuFilterViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/30.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DanmakuFilterViewController.h"
#import "DanmakuFilterDetailViewController.h"

#import "JHBaseTableView.h"
#import "DanmakuFilterTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "JHEdgeButton.h"

@interface DanmakuFilterViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) JHBaseTableView *tableView;
@end

@implementation DanmakuFilterViewController
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
    
    NSArray <JHFilter *>*filters = [[CacheManager shareCacheManager] danmakuFilters];
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
    DanmakuFilterDetailViewController *vc = [[DanmakuFilterDetailViewController alloc] init];
    @weakify(self)
    vc.addFilterCallback = ^(JHFilter *model) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[CacheManager shareCacheManager] updateFilter:model];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CacheManager shareCacheManager].danmakuFilters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DanmakuFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DanmakuFilterTableViewCell" forIndexPath:indexPath];
    cell.model = [CacheManager shareCacheManager].danmakuFilters[indexPath.row];
    @weakify(self)
    cell.touchEnableButtonCallBack = ^(JHFilter *aModel) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[CacheManager shareCacheManager] updateFilter:aModel];
    };
    
    cell.touchRegexButtonCallBack = ^(JHFilter *aModel) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[CacheManager shareCacheManager] updateFilter:aModel];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->_isUpdateFilter = YES;
        JHFilter *model = [CacheManager shareCacheManager].danmakuFilters[indexPath.row];
        [[CacheManager shareCacheManager] removeFilter:model];
        [self.tableView reloadData];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"DanmakuFilterTableViewCell" cacheByIndexPath:indexPath configuration:^(DanmakuFilterTableViewCell *cell) {
        cell.model = [CacheManager shareCacheManager].danmakuFilters[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DanmakuFilterDetailViewController *vc = [[DanmakuFilterDetailViewController alloc] init];
    vc.model = [CacheManager shareCacheManager].danmakuFilters[indexPath.row];
    @weakify(self)
    vc.addFilterCallback = ^(JHFilter *model) {
        @strongify(self)
        if (!self) return;
        
        self->_isUpdateFilter = YES;
        [[CacheManager shareCacheManager] updateFilter:model];
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
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[DanmakuFilterTableViewCell class] forCellReuseIdentifier:@"DanmakuFilterTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [FilterNetManager cloudFilterListWithCompletionHandler:^(JHFilterCollection *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error atView:self.view];
                }
                else {
                    
                    NSArray <JHFilter *>*filters = [[CacheManager shareCacheManager] danmakuFilters];
                    if (filters.count == 0) {
                        [[CacheManager shareCacheManager] addFilters:responseObject.collection];
                    }
                    else {
                        NSMutableArray *removeArr = [NSMutableArray array];
                        
                        [filters enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSInteger index = [responseObject.collection indexOfObject:obj];
                            //将本地列表的状态更新到云端列表
                            if (index != NSNotFound) {
                                JHFilter *aObj = responseObject.collection[index];
                                aObj.enable = obj.enable;
                            }
                            
                            //云端列表
                            if (obj.identity == 0) {
                                [removeArr addObject:obj];
                            }
                        }];
                        
                        [[CacheManager shareCacheManager] removeFilters:removeArr];
                        [[CacheManager shareCacheManager] addFilters:responseObject.collection atHeader:YES];
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
