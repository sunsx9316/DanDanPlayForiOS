//
//  DDPAttentionListViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPAttentionListViewController.h"
#import "DDPAttentionDetailViewController.h"

#import "DDPBaseTableView.h"
#import "DDPAttentionListTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "DDPTextHeaderView.h"
#import "HomePageSearchFilterView.h"
#import "HomePageSearchFilterModel.h"
#import "DDPSearchBar.h"
#import "DDPExpandView.h"
#import "NSString+Tools.h"
#import "NSDate+Tools.h"

@interface DDPAttentionListViewController ()<UITableViewDelegate, UITableViewDataSource, HomePageSearchFilterViewDataSource, HomePageSearchFilterViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) HomePageSearchFilterView *filterView;
@property (strong, nonatomic) NSArray <HomePageSearchFilterModel *>*filterMenuDataSource;

@property (strong, nonatomic) DDPBaseCollection *responseObject;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray *>*modelDic;
@property (strong, nonatomic) NSMutableArray <NSString *>*sectionIndexTitles;
@property (strong, nonatomic) DDPSearchBar *searchBar;
@end

@implementation DDPAttentionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTitleView];
    
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self userfilterDataSource];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionIndexTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelDic[_sectionIndexTitles[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPAttentionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPAttentionListTableViewCell" forIndexPath:indexPath];
    if (self.type == DDPAnimateListTypeAttention) {
        DDPFavorite *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
        cell.model = model;
    }
    else {
        DDPBangumiQueueIntro *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
        cell.infoModel = model;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;
    DDPFavorite *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否取消关注“%@”", model.name] preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.view showLoading];
        [DDPFavoriteNetManagerOperation favoriteLikeWithUser:[DDPCacheManager shareCacheManager].currentUser animeId:model.identity like:NO completionHandler:^(NSError *error) {
            [self.view hideLoading];
            
            if (error) {
                [self.view showWithError:error];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:ATTENTION_SUCCESS_NOTICE object:@(model.identity) userInfo:@{ATTENTION_KEY : @(NO)}];
                
                NSString *title = _sectionIndexTitles[indexPath.section];
                NSMutableArray *arr = self.modelDic[title];
                [arr removeObjectAtIndex:index];
                
                [self.responseObject.collection enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof DDPBase * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    
    DDPTextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPTextHeaderView"];
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
    if (self.type == DDPAnimateListTypeAttention) {
        DDPFavorite *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
        DDPAttentionDetailViewController *vc = [[DDPAttentionDetailViewController alloc] init];
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
    else {
        DDPBangumiQueueIntro *model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
        DDPAttentionDetailViewController *vc = [[DDPAttentionDetailViewController alloc] init];
        vc.animateId = model.identity;
        vc.isOnAir = model.isOnAir;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"DDPAttentionListTableViewCell" cacheByIndexPath:indexPath configuration:^(DDPAttentionListTableViewCell *cell) {
        if (self.type == 0) {
            cell.model = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
        }
        else {
            cell.infoModel = self.modelDic[_sectionIndexTitles[indexPath.section]][indexPath.row];
        }
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消关注";
}

#pragma mark - HomePageSearchFilterViewDataSource
- (NSInteger)numberOfSection {
    return self.filterMenuDataSource.count;
}

- (NSInteger)numberOfItemAtSection:(NSInteger)section {
    return self.filterMenuDataSource[section].subItems.count;
}

- (NSString *)itemTitleAtIndexPath:(NSIndexPath *)indexPath {
    return self.filterMenuDataSource[indexPath.section].subItems[indexPath.row];
}

#pragma mark - HomePageSearchFilterViewDelegate
- (void)pageSearchFilterView:(HomePageSearchFilterView *)view
  didSelectedItemAtIndexPath:(NSIndexPath *)indexPath
                       title:(NSString *)title {
    [self userfilterDataSource];
    [self.tableView reloadData];
}

- (NSInteger)defaultSelectedItemAtSection:(NSInteger)section {
    if (section == 1 && self.type == DDPAnimateListTypeProgress) {
        return 2;
    }
    return 0;
}

- (CGFloat)widthAtSection:(NSInteger)section {
    NSInteger width = (NSInteger)(self.view.width / self.filterMenuDataSource.count);
    return width;
}

#pragma mark - 私有方法
- (void)userfilterDataSource {
    [self.modelDic removeAllObjects];
    
    //用户关注
    if (self.type == DDPAnimateListTypeAttention) {
        NSInteger onAirIndex = [self.filterView selectedItemIndexAtSection:0];
        NSInteger viewIndex = [self.filterView selectedItemIndexAtSection:1];
        NSInteger sortIndex = [self.filterView selectedItemIndexAtSection:2];
        
        NSArray <DDPFavorite *>*filterArr = nil;
        if (self.searchBar.text.length == 0) {
            filterArr = self.responseObject.collection;
        }
        else {
            filterArr = [self.responseObject.collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", self.searchBar.text]];
        }
        
        
        NSMutableArray <DDPFavorite *>*realDataSource = [NSMutableArray array];
        [filterArr enumerateObjectsUsingBlock:^(DDPFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL onAirCanAdd = onAirIndex == 0 || (onAirIndex == 1 && obj.isOnAir) || (onAirIndex == 2 && obj.isOnAir == NO);
            BOOL viewCanAdd = viewIndex == 0 || (viewIndex == 1 && obj.episodeWatched < obj.episodeTotal) || (viewIndex == 2 && obj.episodeWatched >= obj.episodeTotal);
            
            if (onAirCanAdd && viewCanAdd) {
                [realDataSource addObject:obj];
            }
        }];
        
        if (sortIndex > 0) {
            [realDataSource sortUsingComparator:^NSComparisonResult(DDPFavorite * _Nonnull obj1, DDPFavorite * _Nonnull obj2) {
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
            [realDataSource enumerateObjectsUsingBlock:^(DDPFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    //未看完的新番
    else {
        NSInteger bungumiTypeIndex = [self.filterView selectedItemIndexAtSection:0];
        NSInteger sortIndex = [self.filterView selectedItemIndexAtSection:1];
        
        NSArray <DDPBangumiQueueIntro *>*filterArr = nil;
        if (self.searchBar.text.length == 0) {
            filterArr = self.responseObject.collection;
        }
        else {
            filterArr = [self.responseObject.collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", self.searchBar.text]];
        }
        
        
        NSMutableArray <DDPBangumiQueueIntro *>*realDataSource = [NSMutableArray array];
        [filterArr enumerateObjectsUsingBlock:^(DDPBangumiQueueIntro * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //选择了全部 选择了近期追番并且时间不为空 选择了未看新番时间为空
            BOOL canAdd = bungumiTypeIndex == 0 || (bungumiTypeIndex == 1 && obj.lastWatched.length) || (bungumiTypeIndex == 2 && obj.lastWatched.length == 0 );
            
            if (canAdd) {
                [realDataSource addObject:obj];
            }
        }];
        
        if (sortIndex > 0) {
            [realDataSource sortUsingComparator:^NSComparisonResult(DDPBangumiQueueIntro * _Nonnull obj1, DDPBangumiQueueIntro * _Nonnull obj2) {
                //关注时间顺序
                if (sortIndex == 1) {
                    return [obj1.lastWatched compare:obj2.lastWatched];
                }
                //关注时间倒序
                else if (sortIndex == 2) {
                    return [obj2.lastWatched compare:obj1.lastWatched];
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
            [realDataSource enumerateObjectsUsingBlock:^(DDPBangumiQueueIntro * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
}

- (void)configTitleView {
    DDPExpandView *searchBarHolderView = [[DDPExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    [searchBarHolderView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_offset(0);
        make.trailing.mas_offset(0);
        make.top.bottom.mas_equalTo(0);
    }];
    self.navigationItem.titleView = searchBarHolderView;
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.sectionIndexColor = [UIColor ddp_mainColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        [_tableView registerClass:[DDPAttentionListTableViewCell class] forCellReuseIdentifier:@"DDPAttentionListTableViewCell"];
        [_tableView registerClass:[DDPTextHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPTextHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            if (self.type == DDPAnimateListTypeAttention) {
                [DDPFavoriteNetManagerOperation favoriteAnimateWithUser:[DDPCacheManager shareCacheManager].currentUser completionHandler:^(DDPFavoriteCollection *responseObject, NSError *error) {
                    @strongify(self)
                    if (!self) return;
                    
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        self.responseObject = responseObject;
                        self.searchBar.text = nil;
                        [self.filterView reloadData];
                        [self userfilterDataSource];
                        self.filterView.hidden = NO;
                        [self.tableView reloadData];
                    }
                    
                    [self.tableView endRefreshing];
                }];
            }
            else {
                [DDPPlayHistoryNetManagerOperation playHistoryDetailWithUser:[DDPCacheManager shareCacheManager].currentUser completionHandler:^(DDPBangumiQueueIntroCollection *collection, NSError *error) {
                    @strongify(self)
                    if (!self) return;
                    
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        //加上没看的番剧
                        if (collection.unwatchedBangumiList.count) {
                            [collection.collection addObjectsFromArray:collection.unwatchedBangumiList];
                        }
                        
                        self.responseObject = collection;
                        self.searchBar.text = nil;
                        [self.filterView reloadData];
                        [self userfilterDataSource];
                        self.filterView.hidden = NO;
                        [self.tableView reloadData];
                    }
                    
                    [self.tableView endRefreshing];
                }];
            }
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

- (DDPSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[DDPSearchBar alloc] init];
        _searchBar.placeholder = @"搜索番剧";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (NSMutableDictionary<NSString *, NSMutableArray *> *)modelDic {
    if (_modelDic == nil) {
        _modelDic = [NSMutableDictionary dictionary];
    }
    return _modelDic;
}

- (NSArray<HomePageSearchFilterModel *> *)filterMenuDataSource {
    if (_filterMenuDataSource == nil) {
        
        NSMutableArray *arr = [NSMutableArray array];
        
        if (self.type == DDPAnimateListTypeAttention) {
            [arr addObject:({
                HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
                model.title = @"全部";
                model.subItems = @[@"全部", @"正在连载", @"已完结"];
                model;
            })];
            
            [arr addObject:({
                HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
                model.title = @"全部";
                model.subItems = @[@"全部", @"未看完", @"已看完"];
                model;
            })];
            
            [arr addObject:({
                HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
                model.title = @"默认";
                model.subItems = @[@"默认", @"关注时间顺序", @"关注时间倒序", @"名称顺序", @"名称倒序"];
                model;
            })];
        }
        else {
            [arr addObject:({
                HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
                model.title = @"全部";
                model.subItems = @[@"全部", @"近期追番", @"未看新番"];
                model;
            })];
            
            [arr addObject:({
                HomePageSearchFilterModel *model = [[HomePageSearchFilterModel alloc] init];
                model.title = @"默认";
                model.subItems = @[@"默认", @"观看时间顺序", @"观看时间倒序", @"名称顺序", @"名称倒序"];
                model;
            })];
        }
        
        
        _filterMenuDataSource = arr;
    }
    return _filterMenuDataSource;
}

@end
