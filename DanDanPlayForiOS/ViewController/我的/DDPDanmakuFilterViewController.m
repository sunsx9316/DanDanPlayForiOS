//
//  DDPDanmakuFilterViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/30.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDanmakuFilterViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import <BlocksKit/BlocksKit.h>

#import "DDPDanmakuFilterDetailViewController.h"
#import "DDPBaseTableView.h"
#import "DDPDanmakuFilterTableViewCell.h"
#import "DDPEdgeButton.h"
#import "DDPCacheManager+multiply.h"
#import "DDPTextHeaderView.h"

@interface DDPDanmakuFilterViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;

@property (nonatomic, assign) BOOL isUpdateFilter;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray <DDPFilter *>*>*filterDanmausDic;
@property (nonatomic, strong) NSArray <NSString *>*keys;
@end

@implementation DDPDanmakuFilterViewController

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
        
        self.isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:model];
        [self reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    let key = self.keys[section];
    return self.filterDanmausDic[key].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    let model = [self filterWithIndexPath:indexPath];
    
    DDPDanmakuFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPDanmakuFilterTableViewCell" forIndexPath:indexPath];
    cell.model = model;
    @weakify(self)
    cell.touchEnableButtonCallBack = ^(DDPFilter *aModel) {
        @strongify(self)
        if (!self) return;
        
        self.isUpdateFilter = YES;
        if (aModel.isCloudRule) {
            let danmakuFilters = [DDPCacheManager.shareCacheManager.danmakuFilters bk_select:^BOOL(DDPFilter *obj) {
                obj.enable = aModel.enable;
                return obj.isCloudRule;
            }];
            [[DDPCacheManager shareCacheManager] addFilters:danmakuFilters];
        } else {
            [[DDPCacheManager shareCacheManager] addFilter:aModel];
        }
    };
    
    cell.touchRegexButtonCallBack = ^(DDPFilter *aModel) {
        @strongify(self)
        if (!self) return;
        
        self.isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:aModel];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isUpdateFilter = YES;
        let model = [self filterWithIndexPath:indexPath];
        [[DDPCacheManager shareCacheManager] removeFilter:model];
        [self reloadData];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"DDPDanmakuFilterTableViewCell" cacheByIndexPath:indexPath configuration:^(DDPDanmakuFilterTableViewCell *cell) {
        cell.model = [self filterWithIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    let model = [self filterWithIndexPath:indexPath];
    
    if (model.isCloudRule) {
        return;
    }
    
    DDPDanmakuFilterDetailViewController *vc = [[DDPDanmakuFilterDetailViewController alloc] init];
    vc.model = model;
    @weakify(self)
    vc.addFilterCallback = ^(DDPFilter *model) {
        @strongify(self)
        if (!self) return;
        
        self.isUpdateFilter = YES;
        [[DDPCacheManager shareCacheManager] addFilter:model];
        [self reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    let model = [self filterWithIndexPath:indexPath];
    return !model.isCloudRule;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    let key = self.keys[section];
    DDPTextHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:DDPTextHeaderView.className];
    headerView.titleLabel.text = key;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - Private Method
- (void)reloadData {
    NSArray <DDPFilter *>*filters = DDPCacheManager.shareCacheManager.danmakuFilters;
    
    [self.filterDanmausDic removeAllObjects];
    
    self.filterDanmausDic[@"自定义规则"] = [filters bk_select:^BOOL(DDPFilter *obj) {
        return !obj.isCloudRule;
    }].mutableCopy;
    
    
    self.filterDanmausDic[@"云端规则"] = ^{
        DDPFilter *aFilter = [[DDPFilter alloc] init];
        aFilter.name = @"云端规则";
        aFilter.cloudRule = YES;
        
        DDPFilter *aCloudFilter = [filters bk_match:^BOOL(DDPFilter *obj) {
            return obj.isCloudRule;
        }];
        
        aFilter.enable = aCloudFilter.enable;
        
        return [NSMutableArray arrayWithObject:aFilter];
    }();
    
    self.keys = [self.filterDanmausDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    [self.tableView reloadData];
}

- (DDPFilter *)filterWithIndexPath:(NSIndexPath *)indexPath {
    let key = self.keys[indexPath.section];
    return self.filterDanmausDic[key][indexPath.row];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[DDPDanmakuFilterTableViewCell class] forCellReuseIdentifier:@"DDPDanmakuFilterTableViewCell"];
        [_tableView registerClass:[DDPTextHeaderView class] forHeaderFooterViewReuseIdentifier:DDPTextHeaderView.className];
        
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
                    
                    NSArray <DDPFilter *>*filters = DDPCacheManager.shareCacheManager.danmakuFilters;
                    
                    if (filters.count == 0) {
                        [[DDPCacheManager shareCacheManager] addFilters:responseObject.collection];
                    }
                    else {
                        
                        let cloudRules = responseObject.collection;
                        
                        DDPFilter *aCloudFilter = [filters bk_match:^BOOL(DDPFilter *obj) {
                            return obj.isCloudRule;
                        }];
                        //设置云端弹幕状态
                        [cloudRules enumerateObjectsUsingBlock:^(DDPFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            obj.enable = aCloudFilter.enable;
                        }];
                        //删除本地缓存的远端弹幕
                        NSArray <DDPFilter *>*oldCloudRules = [filters bk_select:^BOOL(DDPFilter *obj) {
                            BOOL sameName = [cloudRules bk_any:^BOOL(DDPFilter *obj1) {
                                return [obj.name isEqual:obj1.name];
                            }];
                            
                            if (obj.isCloudRule || sameName) {
                                return YES;
                            }
                            return NO;
                        }];
                        
                        //删除云端弹幕
                        [[DDPCacheManager shareCacheManager] removeFilters:oldCloudRules];
                        //保存云端弹幕
                        [[DDPCacheManager shareCacheManager] addFilters:cloudRules];
                    }
                    
                    [self reloadData];
                }
                
                [self.tableView endRefreshing];
            }];
        }];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableDictionary<NSString *,NSMutableArray<DDPFilter *> *> *)filterDanmausDic {
    if (_filterDanmausDic == nil) {
        _filterDanmausDic = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _filterDanmausDic;
}

@end
