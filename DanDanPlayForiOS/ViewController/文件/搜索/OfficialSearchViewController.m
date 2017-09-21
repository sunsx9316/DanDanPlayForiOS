//
//  OfficialSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "OfficialSearchViewController.h"
#import "PlayerViewController.h"
#import "PlayNavigationController.h"

#import "SearchAnimeTitleTableViewCell.h"
#import "SearchEpisodeTableViewCell.h"
#import "MatchTitleTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

#import "BaseTreeView.h"

@interface OfficialSearchViewController ()<RATreeViewDelegate, RATreeViewDataSource>
@property (strong, nonatomic) BaseTreeView *treeView;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSMutableArray <JHSearch *>*>*classifyDic;
@end

@implementation OfficialSearchViewController
{
    NSArray <NSNumber *>*_resortKeys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.treeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.treeView.jh_tableView.mj_header beginRefreshing];
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    if (self.isViewLoaded) {
        [self.treeView.jh_tableView.mj_header beginRefreshing];
    }
}

#pragma mark - RATreeViewDelegate
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    if ([item isKindOfClass:[NSNumber class]] || [item isKindOfClass:[JHSearch class]]) {
        return 44;
    }
    
    JHEpisode *episode = item;
    return [treeView.jh_tableView fd_heightForCellWithIdentifier:@"SearchEpisodeTableViewCell" cacheByKey:item configuration:^(SearchEpisodeTableViewCell *cell) {
        cell.titleLabel.text = episode.name;
    }];
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
    if ([item isKindOfClass:[NSNumber class]] || [item isKindOfClass:[JHSearch class]]) {
        MatchTitleTableViewCell *cell = (MatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:YES animate:YES];
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
    if ([item isKindOfClass:[NSNumber class]] || [item isKindOfClass:[JHSearch class]]) {
        MatchTitleTableViewCell *cell = (MatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:NO animate:YES];
    }
}

- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(JHFile *)item {
    return UITableViewCellEditingStyleNone;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(JHEpisode *)item {
    [treeView deselectRowForItem:item animated:YES];
    if ([item isKindOfClass:[JHEpisode class]]) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        
        [CommentNetManager danmakusWithEpisodeId:item.identity progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = jh_danmakusProgressToString(progress);
        } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
            [aHUD hideAnimated:YES];
            self.model.danmakus = responseObject;
            self.model.matchName = item.name;
            self.model.identity = item.identity;
            
            __block PlayerViewController *vc = nil;
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[PlayerViewController class]]) {
                    vc = obj;
                    *stop = YES;
                }
            }];
            
            //更改匹配信息
            [MatchNetManager matchEditMatchVideoModel:self.model user:[CacheManager shareCacheManager].user completionHandler:^(NSError *error) {
                NSLog(@"%@", error);
            }];
            
            if (vc) {
                vc.model = self.model;
                [self.navigationController popToViewController:vc animated:YES];
            }
            else {
                PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:self.model];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - RATreeViewDataSource
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys.count;
    }
    
    if ([item isKindOfClass:[NSNumber class]]) {
        NSArray *arr = self.classifyDic[item];
        return arr.count;
    }
    
    if ([item isKindOfClass:[JHSearch class]]) {
        return [item episodes].count;
    }
    
    return 0;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(nullable id)item {
    if ([item isKindOfClass:[NSNumber class]]) {
        MatchTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"MatchTitleTableViewCell"];
        cell.titleLabel.text = jh_episodeTypeToString([item integerValue]);
        [cell expandArrow:[treeView isCellForItemExpanded:item] animate:NO];
        return cell;
    }
    
    if ([item isKindOfClass:[JHSearch class]]) {
        SearchAnimeTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"SearchAnimeTitleTableViewCell"];
        cell.titleLabel.text = [item name];
        [cell expandArrow:[treeView isCellForItemExpanded:item] animate:NO];
        return cell;
    }
    
    JHEpisode *episode = item;
    SearchEpisodeTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"SearchEpisodeTableViewCell"];
    cell.titleLabel.text = episode.name;
    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys[index];
    }
    
    if ([item isKindOfClass:[NSNumber class]]) {
        return self.classifyDic[item][index];
    }
    
    return [item episodes][index];
    
}

#pragma mark - 私有方法
- (void)classifyWithColletion:(JHSearchCollection *)collection {
    [self.classifyDic removeAllObjects];
    
    [collection.collection enumerateObjectsUsingBlock:^(JHSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.classifyDic[@(obj.type)] == nil) {
            self.classifyDic[@(obj.type)] = [NSMutableArray array];
        }
        
        [self.classifyDic[@(obj.type)] addObject:obj];
    }];
    
    _resortKeys = [[self.classifyDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}



#pragma mark - 懒加载
- (BaseTreeView *)treeView {
    if (_treeView == nil) {
        _treeView = [[BaseTreeView alloc] initWithFrame:CGRectZero style:RATreeViewStylePlain];
        _treeView.delegate = self;
        _treeView.dataSource = self;
        _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
        _treeView.rowsExpandingAnimation = RATreeViewRowAnimationTop;
        _treeView.rowsCollapsingAnimation = RATreeViewRowAnimationTop;
        [_treeView registerClass:[SearchAnimeTitleTableViewCell class] forCellReuseIdentifier:@"SearchAnimeTitleTableViewCell"];
        [_treeView registerClass:[SearchEpisodeTableViewCell class] forCellReuseIdentifier:@"SearchEpisodeTableViewCell"];
        [_treeView registerClass:[MatchTitleTableViewCell class] forCellReuseIdentifier:@"MatchTitleTableViewCell"];
        @weakify(self)
        _treeView.jh_tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            NSArray *keywords = [self.keyword componentsSeparatedByString:@" "];
            
            
            [SearchNetManager searchOfficialWithKeyword:keywords.firstObject episode:[keywords.lastObject integerValue] completionHandler:^(JHSearchCollection *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error atView:self.view];
                }
                else {
                    [self classifyWithColletion:responseObject];
                    [self.treeView reloadData];
                }
                
                [self.treeView endRefreshing];
            }];
        }];
        [self.view addSubview:_treeView];
    }
    return _treeView;
}

- (NSMutableDictionary<NSNumber *,NSMutableArray<JHSearch *> *> *)classifyDic {
    if (_classifyDic == nil) {
        _classifyDic = [NSMutableDictionary dictionary];
    }
    return _classifyDic;
}

@end
