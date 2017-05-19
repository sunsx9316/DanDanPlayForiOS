//
//  MatchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MatchViewController.h"
#import "SearchViewController.h"
#import "PlayNavigationController.h"
#import "PlayerViewController.h"

#import "MatchTableViewCell.h"
#import "MatchTitleTableViewCell.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import "BaseTreeView.h"
#import "JHEdgeButton.h"

@interface MatchViewController ()<RATreeViewDelegate, RATreeViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (strong, nonatomic) BaseTreeView *treeView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSMutableArray <JHMatche *>*>*classifyDic;
@end

@implementation MatchViewController
{
    NSArray <NSNumber *>*_resortKeys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"快速匹配";
    [self configRightItem];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(SEARCH_BAR_HEIRHT);
    }];
    
    [self.treeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
    
    if (self.treeView.jh_tableView.mj_header.refreshingBlock) {
        self.treeView.jh_tableView.mj_header.refreshingBlock();
    }
    
}

#pragma mark - RATreeViewDelegate
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    if ([item isKindOfClass:[NSNumber class]]) {
        return 44;
    }
    
    return [treeView.jh_tableView fd_heightForCellWithIdentifier:@"MatchTableViewCell" cacheByKey:item configuration:^(MatchTableViewCell *cell) {
        cell.model = item;
    }];
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
    if ([item isKindOfClass:[NSNumber class]]) {
        MatchTitleTableViewCell *cell = (MatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:YES animate:YES];
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
    if ([item isKindOfClass:[NSNumber class]]) {
        MatchTitleTableViewCell *cell = (MatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:NO animate:YES];
    }
}

- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(JHFile *)item {
    return UITableViewCellEditingStyleNone;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(JHMatche *)item {
    [treeView deselectRowForItem:item animated:YES];
    if ([item isKindOfClass:[JHMatche class]]) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];

        [CommentNetManager danmakusWithEpisodeId:item.identity progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = danmakusProgressToString(progress);
        } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
            [aHUD hideAnimated:NO];
            self.model.danmakus = responseObject;
            self.model.matchName = item.name;
            [self jumpToOtherVC];
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
    
    return 0;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(nullable id)item {
    if ([item isKindOfClass:[NSNumber class]]) {
        MatchTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"MatchTitleTableViewCell"];
        cell.titleLabel.text = JHEpisodeTypeToString([item integerValue]);
        [cell expandArrow:[treeView isCellForItemExpanded:item] animate:NO];
        return cell;
    }
    
    MatchTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"MatchTableViewCell"];
    cell.model = item;
    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys[index];
    }
    
    return self.classifyDic[item][index];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        SearchViewController *vc = [[SearchViewController alloc] init];
        vc.model = self.model;
        vc.keyword = searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击直接播放" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.treeView.showEmptyView;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self jumpToOtherVC];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - 私有方法
- (void)classifyWithColletion:(JHMatcheCollection *)collection {
    [self.classifyDic removeAllObjects];
    
    [collection.collection enumerateObjectsUsingBlock:^(JHMatche * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.classifyDic[@(obj.type)] == nil) {
            self.classifyDic[@(obj.type)] = [NSMutableArray array];
        }
        
        [self.classifyDic[@(obj.type)] addObject:obj];
    }];
    
    _resortKeys = [[self.classifyDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

- (void)jumpToOtherVC {
    __block PlayerViewController *vc = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PlayerViewController class]]) {
            vc = obj;
            *stop = YES;
        }
    }];
    
    if (vc) {
        vc.model = self.model;
        [self.navigationController popToViewController:vc animated:YES];
    }
    else {
        PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:self.model];
        [self presentViewController:nav animated:YES completion:nil];
    }

}

- (void)configRightItem {
    JHEdgeButton *backButton = [[JHEdgeButton alloc] init];
    backButton.inset = CGSizeMake(10, 10);
    [backButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"直接播放" forState:UIControlStateNormal];
    [backButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)touchRightItem:(UIButton *)button {
    [self jumpToOtherVC];
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
        _treeView.jh_tableView.emptyDataSetSource = self;
        _treeView.jh_tableView.emptyDataSetDelegate = self;
        [_treeView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchTableViewCell"];
        [_treeView registerClass:[MatchTitleTableViewCell class] forCellReuseIdentifier:@"MatchTitleTableViewCell"];
        @weakify(self)
        _treeView.jh_tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [MatchNetManager matchVideoModel:self.model completionHandler:^(JHMatcheCollection *responseObject, NSError *error) {
                if (error) {
                    [MBProgressHUD showWithError:error];
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

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"找不到？试试手动♂搜索";
        _searchBar.returnKeyType = UIReturnKeySearch;
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

- (NSMutableDictionary<NSNumber *,NSMutableArray<JHMatche *> *> *)classifyDic {
    if (_classifyDic == nil) {
        _classifyDic = [NSMutableDictionary dictionary];
    }
    return _classifyDic;
}

@end
