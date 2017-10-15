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

@interface AttentionListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) JHBaseTableView *tableView;
//@property (strong, nonatomic) JHFavoriteCollection *model;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <JHFavorite *>*>*modelDic;
@end

@implementation AttentionListViewController
{
    NSMutableArray <NSString *>*_sectionIndexTitles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的关注";
    
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
            if (arr.count == 0) {
                [_sectionIndexTitles removeObject:title];
                [tableView deleteSection:indexPath.section withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView reloadEmptyDataSet];
        }
    }];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionIndexTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TextHeaderView"];
    view.titleLabel.text = _sectionIndexTitles[section];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
//                    self.model = responseObject;
                    [self.modelDic removeAllObjects];
                    [responseObject.collection enumerateObjectsUsingBlock:^(JHFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *index = [obj.name pinYinIndex];
                        if (self.modelDic[index] == nil) {
                            self.modelDic[index] = [NSMutableArray array];
                        }
                        
                        [self.modelDic[index] addObject:obj];
                    }];
                    
                    _sectionIndexTitles = [[self.modelDic allKeysSorted] mutableCopy];
                    
                    [self.tableView reloadData];
                }
                
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableDictionary<NSString *,NSMutableArray<JHFavorite *> *> *)modelDic {
    if (_modelDic == nil) {
        _modelDic = [NSMutableDictionary dictionary];
    }
    return _modelDic;
}

@end
