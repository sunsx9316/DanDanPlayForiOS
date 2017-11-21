//
//  AttentionListViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionListViewController.h"
#import "AttentionDetailViewController.h"

#import "JHBaseTableView.h"
#import "AttentionListTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSString+Tools.h"
#import "TextHeaderView.h"
#import "HomePageSearchFilterView.h"
#import "HomePageSearchFilterModel.h"

@interface AttentionListViewController ()<UITableViewDelegate, UITableViewDataSource, HomePageSearchFilterViewDataSource, HomePageSearchFilterViewDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) HomePageSearchFilterView *filterView;
@property (strong, nonatomic) JHFavoriteCollection *responseObject;

@property (strong, nonatomic) NSArray <HomePageSearchFilterModel *>*filterDataSource;


@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <JHFavorite *>*>*modelDic;
@property (strong, nonatomic) NSMutableArray <NSString *>*sectionIndexTitles;
@end

@implementation AttentionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的关注";
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(FILTER_VIEW_HEIGHT);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.filterView.mas_bottom);
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefresh {
    [self.tableView endRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionIndexTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelDic[_sectionIndexTitles[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttentionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttentionListTableViewCell" forIndexPath:indexPath];
    JHFavorite *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;
    JHFavorite *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:    [NSString stringWithFormat:@"是否取消关注%@", model.name] message:@"操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showLoadingInView:self.view text:nil];
        [FavoriteNetManager favoriteLikeWithUser:[CacheManager shareCacheManager].user animeId:model.identity like:NO completionHandler:^(NSError *error) {
            [MBProgressHUD hideLoading];
            
            if (error) {
                [MBProgressHUD showWithError:error atView:self.view];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:ATTENTION_SUCCESS_NOTICE object:@(model.identity) userInfo:@{ATTENTION_KEY : @(NO)}];
                
                NSString *title = _sectionIndexTitles[indexPath.section];
                NSMutableArray *arr = self.modelDic[title];
                [arr removeObjectAtIndex:index];
                
                [self.responseObject.collection enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof JHBase * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.identity == model.identity) {
                        [self.responseObject.collection removeObjectAtIndex:idx];
                    }
                }];
                
                if (arr.count == 0) {
                    [self.sectionIndexTitles removeObject:title];
                    [tableView deleteSection:indexPath.section withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else {
                    [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                [self.tableView reloadEmptyDataSet];
            }
        }];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionIndexTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = _sectionIndexTitles[section];
    if (title.length == 0) {
        return nil;
    }
    
    TextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TextHeaderView"];
    view.titleLabel.text = title;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = _sectionIndexTitles[section];
    if (title.length == 0) {
        return CGFLOAT_MIN;
    }
    
    return 30;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JHFavorite *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
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
        cell.model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消关注";
}

#pragma mark - HomePageSearchFilterViewDataSource
- (NSInteger)numberOfItem {
    return self.filterDataSource.count;
}

- (NSString *)itemTitleAtSection:(NSInteger)index {
    return self.filterDataSource[index].title;
}

- (NSInteger)numberOfSubItemAtSection:(NSInteger)index {
    return self.filterDataSource[index].subItems.count;
}

- (NSString *)subItemTitleAtIndex:(NSInteger)index section:(NSInteger)section {
    return self.filterDataSource[section].subItems[index];
}

#pragma mark - HomePageSearchFilterViewDelegate
- (void)pageSearchFilterView:(HomePageSearchFilterView *)view didSelectedSubItemAtIndex:(NSInteger)index
                     section:(NSInteger)section
                       title:(NSString *)title {
    [self userfilterDataSource];
    [self.tableView reloadData];
}

#pragma mark - 私有方法
- (void)userfilterDataSource {
    [self.modelDic removeAllObjects];
    NSInteger onAirIndex = [self.filterView selectedItemIndexAtSection:0];
    NSInteger viewIndex = [self.filterView selectedItemIndexAtSection:1];
    NSInteger sortIndex = [self.filterView selectedItemIndexAtSection:2];
    
    
    NSMutableArray <JHFavorite *>*realDataSource = [NSMutableArray array];
    
    [self.responseObject.collection enumerateObjectsUsingBlock:^(JHFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL onAirCanAdd = onAirIndex == 0 || (onAirIndex == 1 && obj.isOnAir) || (onAirIndex == 2 && obj.isOnAir == NO);
        BOOL viewCanAdd = viewIndex == 0 || (viewIndex == 1 && obj.episodeWatched < obj.episodeTotal) || (viewIndex == 2 && obj.episodeWatched >= obj.episodeTotal);
        
        if (onAirCanAdd && viewCanAdd) {
            [realDataSource addObject:obj];
        }
    }];
    
    if (sortIndex > 0) {
        [realDataSource sortUsingComparator:^NSComparisonResult(JHFavorite * _Nonnull obj1, JHFavorite * _Nonnull obj2) {
            //关注时间顺序
            if (sortIndex == 1) {
                return [obj1.attentionTime compare:obj2.attentionTime];
            }
            //关注时间倒序
            else if (sortIndex == 2) {
                return [obj2.attentionTime compare:obj1.attentionTime];
            }
            //名称顺序
            else if (sortIndex == 3) {
                return [obj1.name compare:obj2.name];
            }
            //名称倒序
            return [obj2.name compare:obj1.name];
        }];
        
        self.modelDic[@""] = realDataSource;
    }
    else {
        [realDataSource enumerateObjectsUsingBlock:^(JHFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //拼音索引
            NSString *index = [obj.name pinYinIndex];
            if (self.modelDic[index] == nil) {
                self.modelDic[index] = [NSMutableArray array];
            }
            
            [self.modelDic[index] addObject:obj];
        }];
    }
    
    self.sectionIndexTitles = [[self.modelDic allKeysSorted] mutableCopy];
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.sectionIndexColor = MAIN_COLOR;
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        [_tableView registerClass:[AttentionListTableViewCell class] forCellReuseIdentifier:@"AttentionListTableViewCell"];
        [_tableView registerClass:[TextHeaderView class] forHeaderFooterViewReuseIdentifier:@"TextHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [FavoriteNetManager favoriteAnimateWithUser:[CacheManager shareCacheManager].user completionHandler:^(JHFavoriteCollection *responseObject, NSError *error) {
                @strongify(self)
                if (!self) return;
                
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    self.responseObject = responseObject;
                    [self.filterView reloadData];
                    [self userfilterDataSource];
                    self.filterView.hidden = NO;
                    [self.tableView reloadData];
                }
                
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (HomePageSearchFilterView *)filterView {
    if (_filterView == nil) {
        _filterView = [[HomePageSearchFilterView alloc] init];
        _filterView.dataSource = self;
        _filterView.delegate = self;
        _filterView.hidden = YES;
        [self.view addSubview:_filterView];
    }
    return _filterView;
}

- (NSMutableDictionary<NSString *,NSMutableArray<JHFavorite *> *> *)modelDic {
    if (_modelDic == nil) {
        _modelDic = [NSMutableDictionary dictionary];
    }
    return _modelDic;
}

- (NSArray<HomePageSearchFilterModel *> *)filterDataSource {
    if (_filterDataSource == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        {
            HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
            model.title = @"全部";
            model.subItems = @[@"全部", @"正在连载", @"已完结"];
            [arr addObject:model];
        }
        
        {
            HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
            model.title = @"全部";
            model.subItems = @[@"全部", @"未看完", @"已看完"];
            [arr addObject:model];
        }
        
        {
            HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
            model.title = @"默认";
            model.subItems = @[@"默认", @"关注时间顺序", @"关注时间倒序", @"名称顺序", @"名称倒序"];
            [arr addObject:model];
        }
        
        _filterDataSource = arr;
    }
    return _filterDataSource;
}

@end
